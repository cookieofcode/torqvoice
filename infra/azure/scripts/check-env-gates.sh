#!/usr/bin/env bash
# Targeted checks for the environment / TLS gate. No Azure credentials required.
# PR CI (.github/workflows/terraform.yml) runs this after terraform fmt -check.
#
#   ./scripts/check-env-gates.sh
#
# (a) terraform validate on this root and bootstrap/ (default environment=dev0).
# (b) terraform test in tests/env-gate: environment=prod without TLS fails;
#     environment=dev0 HTTP plans; stale tags.environment=prod does not trip
#     the gate; enable_tls=true fixtures plan (prod and dev0). A live Azure
#     plan of this root still needs az login + Key Vault.
# (c) the offline test module must not drift from variables.tf / locals.tf
#     (and kubernetes.tf load_balancer_ip must stay null when TLS is on).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v terraform >/dev/null; then
  echo "terraform is required" >&2
  exit 2
fi

init_validate() {
  local dir=$1
  echo "==> init -backend=false && validate  ($dir)"
  (cd "$dir" && terraform init -backend=false -input=false -no-color >/dev/null && terraform validate -no-color)
}

echo "==> (c) TLS gate depends only on var.environment (main module + test copy)"
if ! grep -qE '^[[:space:]]*is_prod = var\.environment == "prod"[[:space:]]*$' "$ROOT/locals.tf"; then
  echo "locals.tf: is_prod must be exactly: var.environment == \"prod\"" >&2
  grep -n 'is_prod' "$ROOT/locals.tf" >&2 || true
  exit 1
fi
if ! grep -qE '^[[:space:]]*is_prod[[:space:]]*=[[:space:]]*var\.environment == "prod"[[:space:]]*$' "$ROOT/tests/env-gate/main.tf"; then
  echo "tests/env-gate/main.tf: is_prod must match the workload root" >&2
  exit 1
fi
if awk '
  $0 ~ /^variable "tags"/ { in_tags=1 }
  in_tags && $0 ~ /^variable "/ && $0 !~ /^variable "tags"/ { in_tags=0 }
  in_tags && /enable_tls/ { found=1 }
  END { exit found ? 0 : 1 }
' "$ROOT/variables.tf"; then
  echo "variable \"tags\" must not validate enable_tls / hostname (that was the split-brain)" >&2
  exit 1
fi
if grep -n 'try(var.tags\["environment"\]' "$ROOT"/*.tf; then
  echo "no workload *.tf may consult input tags.environment for the TLS gate" >&2
  exit 1
fi
for snippet in \
  'var.environment != "prod" || (var.enable_tls && trimspace(var.hostname) != "")' \
  'requires enable_tls = true and a non-empty hostname'; do
  if ! grep -qF "$snippet" "$ROOT/variables.tf" || ! grep -qF "$snippet" "$ROOT/tests/env-gate/main.tf"; then
    echo "gate snippet missing from variables.tf or tests/env-gate/main.tf:" >&2
    echo "  $snippet" >&2
    exit 1
  fi
done
if ! grep -qE '^[[:space:]]*load_balancer_ip = local\.tls_enabled \? null' "$ROOT/kubernetes.tf"; then
  echo "kubernetes.tf: TLS-on load_balancer_ip must be null (not empty string)" >&2
  grep -n 'load_balancer_ip' "$ROOT/kubernetes.tf" >&2 || true
  exit 1
fi
if ! grep -qE '^[[:space:]]*load_balancer_ip = local\.tls_enabled \? null' "$ROOT/tests/env-gate/main.tf"; then
  echo "tests/env-gate/main.tf: load_balancer_ip must be null when TLS is on" >&2
  exit 1
fi
echo "ok: main module and tests/env-gate share the same environment-only gate"

init_validate "$ROOT"
init_validate "$ROOT/bootstrap"

echo "==> (a)(b) terraform test in tests/env-gate"
(cd "$ROOT/tests/env-gate" && terraform init -input=false -no-color >/dev/null && terraform test -no-color)

echo "all env-gate checks passed"
