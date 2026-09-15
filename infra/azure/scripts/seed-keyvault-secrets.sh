#!/usr/bin/env bash
# Seed Key Vault with application secrets. Values are never printed and never
# passed through Terraform.
#
# Usage:
#   ./scripts/seed-keyvault-secrets.sh <vault-name>
#   ./scripts/seed-keyvault-secrets.sh <vault-name> --rotate
#
# Creates (or, with --rotate, overwrites):
#   postgres-admin-password  URL-safe, for Flexible Server + ESO DATABASE_URL
#   better-auth-secret       openssl rand -hex 32
#
# Does not create DATABASE_URL: External Secrets templates it from the
# password + the server FQDN that Terraform may store (FQDN is not a secret).
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <key-vault-name> [--rotate]" >&2
  exit 2
fi

VAULT=$1
ROTATE=0
if [[ "${2:-}" == "--rotate" ]]; then
  ROTATE=1
fi

if ! command -v az >/dev/null; then
  echo "az CLI is required" >&2
  exit 1
fi

secret_exists() {
  az keyvault secret show --vault-name "$VAULT" --name "$1" --query name -o tsv >/dev/null 2>&1
}

put_secret() {
  local name=$1
  local value=$2
  az keyvault secret set --vault-name "$VAULT" --name "$name" --value "$value" --only-show-errors >/dev/null
}

if [[ $ROTATE -eq 1 ]] || ! secret_exists postgres-admin-password; then
  # Alphanumeric so DATABASE_URL does not need quoting beyond ESO urlquery.
  pass=$(openssl rand -base64 48 | tr -d '/+=' | head -c 32)
  put_secret postgres-admin-password "$pass"
  echo "set postgres-admin-password"
else
  echo "postgres-admin-password already exists (pass --rotate to replace)"
fi

if [[ $ROTATE -eq 1 ]] || ! secret_exists better-auth-secret; then
  auth=$(openssl rand -hex 32)
  put_secret better-auth-secret "$auth"
  echo "set better-auth-secret"
else
  echo "better-auth-secret already exists (pass --rotate to replace)"
fi

echo "done. Secret values are only in Key Vault, not in this script's output."
