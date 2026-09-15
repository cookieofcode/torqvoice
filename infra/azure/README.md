# Azure Terraform — lean Torqvoice (Switzerland North)

Everything-as-Code for a cost-controlled Torqvoice stack in **Switzerland North**. Azure, Kubernetes, Helm, and Key Vault *structure* live in this directory. Secret **values** do not.

## WARNING — do not apply without Leo's approval

**Do not run `terraform apply` (this root or `bootstrap/`).** Do not provision, mutate, or destroy Azure resources until Leo has reviewed the plan and explicitly approved apply.

Allowed without that approval: `az login`, `terraform init` (`-backend=false` or `-backend-config=backend.hcl`), `terraform fmt`, `terraform validate`, `terraform plan`.

## Terraform state must not contain

| Must not appear in TF state | How this root avoids it |
| --- | --- |
| PostgreSQL admin password | Seeded into Key Vault out-of-band; read with **ephemeral** `azurerm_key_vault_secret`; sent as **`administrator_password_wo`** (write-only) |
| `BETTER_AUTH_SECRET` | Key Vault only; ESO syncs into the cluster |
| `DATABASE_URL` | ESO **templates** it at runtime from KV password + FQDN (FQDN is not a secret) |
| `kubernetes_secret` data | Terraform does not manage Secret data |
| `random_password` / kube admin client keys | Not used. AKS **local accounts disabled**; Entra ID + kubelogin |

**Residual risks (read these):**

- `azurerm` may still persist a computed `kube_config` blob on `azurerm_kubernetes_cluster`. With `local_account_disabled = true` it should **not** contain client keys. We only use the **cluster CA** (not a credential) for the Kubernetes/Helm providers. Humans authenticate with `az aks get-credentials` + [kubelogin](https://github.com/Azure/kubelogin).
- Ephemeral KV reads exist in memory during plan/apply of the Flexible Server; they are not written to state or the plan file. Do not dump `TF_LOG=TRACE` around that apply.
- Never switch Flexible Server to `administrator_password` (non-`_wo`): that attribute **is** stored in state. azurerm has no “password from Key Vault resource ID” for Flexible Server; write-only + ephemeral is the supported escape hatch.
- ESO-created Kubernetes Secrets live in cluster etcd, not Terraform state.
- Helm release values contain the Postgres **FQDN** and KV **names**, not passwords.

## Secret flow

```
bootstrap/  →  rg-torqvoice-tfstate
               ├── Storage (tfstate container, Azure AD only, no access keys)
               └── Key Vault (RBAC; no secret values from Terraform)

human / GitHub Actions OIDC
               └── scripts/seed-keyvault-secrets.sh
                     writes postgres-admin-password, better-auth-secret
                     (openssl; values never printed)

this root     →  ephemeral read of postgres-admin-password
               →  Flexible Server administrator_password_wo
               →  AKS + ESO (Workload Identity) + ExternalSecret *names*
               →  ESO creates Secret/torqvoice in-cluster
```

Who creates secrets: the operator (or a CI job with Key Vault Secrets Officer) running `scripts/seed-keyvault-secrets.sh` **after** bootstrap Key Vault exists and **before** the first plan/apply that creates PostgreSQL.

Where they live: Azure Key Vault in `rg-torqvoice-tfstate`.

How the workload consumes them: External Secrets Operator (Workload Identity, Key Vault Secrets User) → Kubernetes Secret `torqvoice` (`DATABASE_URL`, `BETTER_AUTH_SECRET`). The Deployment also mounts ConfigMap `torqvoice` (`NEXT_PUBLIC_APP_URL` only).

GitHub Actions (OIDC, no long-lived Azure secrets): federate the workflow identity, grant it Key Vault Secrets Officer, run the seed script, then `terraform plan` with `use_azuread_auth`.

## Remote state

The `azurerm` backend cannot interpolate variables. Names are defaults in `bootstrap/` + `backend.hcl.example`.

1. Copy `bootstrap/terraform.tfvars.example` → `bootstrap/terraform.tfvars`, set `subscription_id`.
2. After Leo approves: apply **bootstrap only**, then `terraform output backend_hcl`.
3. Copy that into `backend.hcl` (gitignored). Storage account names are globally unique (`sttorqvoicetfstate` + 4-char suffix unless you set the name).
4. Workload root: `terraform init -backend-config=backend.hcl` (`use_azuread_auth = true`). The same Entra identity needs **Storage Blob Data Contributor** on that account (bootstrap grants it to the applying principal).

Do not store backend access keys. Access keys are disabled on the storage account.

## TLS

| `environment` / `tags.environment` | `enable_tls` + `hostname` | Edge |
| --- | --- | --- |
| `dev0` (default) or `bringup` | false / empty | HTTP LoadBalancer on the static PIP. **Not** a prod posture. |
| `prod` (literal only) | **required** | nginx Ingress + cert-manager + Let's Encrypt HTTP-01. Plan **fails** if prod + HTTP. |

App Gateway WAF is out of scope (cost). Point the hostname A record at `public_ip_address` after the PIP exists.

## Naming

`environment` (default `dev0`) drives Azure resource names and is merged into `tags.environment`. Bootstrap (`rg-torqvoice-tfstate`, Key Vault) is shared and is not renamed.

| Resource | Default name (`environment = "dev0"`) |
| --- | --- |
| Resource group | `rg-torqvoice-dev0` |
| AKS | `aks-torqvoice-dev0` |
| VNet | `vnet-torqvoice-dev0` |
| Public IP | `pip-torqvoice-dev0` |

Override `resource_group_name` / `aks_name` only if you need a different string; empty means derive from `environment`.

## Image pin

Default: `ghcr.io/torqvoice/torqvoice@sha256:6efeb6b22b16e2666ccfc39a85ab102e1dd6ae0492d4896dd2cdc8f72557abad`  
(public index digest of `:latest` on 2026-09-15). `imagePullPolicy: IfNotPresent`.

Bump:

```bash
# digest of a tag (needs a GHCR pull token for private images)
crane digest ghcr.io/torqvoice/torqvoice:v1.2.34
```

`:latest` is rejected by variable validation. Optional private registry: `k8s/image-pull-secret.yaml.example` + `image_pull_secret_name`.

## Layout

| Path | What it defines |
| --- | --- |
| `bootstrap/` | tfstate RG, Storage (versioned, Azure AD), Key Vault + RBAC |
| `versions.tf` | Terraform `>= 1.11`, azurerm `>= 4.2`, helm, kubernetes, **azurerm backend** |
| `identity.tf` | AKS + ESO user-assigned identities, Workload Identity federation |
| `aks.tf` | AKS **Free**, 1× `Standard_B2s`, Entra RBAC, **no local kube accounts**, outbound = the one PIP |
| `postgres.tf` | Flexible Server **B_Standard_B1ms**, 32 GiB, HA off, password **write-only** |
| `helm.tf` | ESO; nginx + cert-manager only when TLS is on |
| `kubernetes.tf` | Namespace, ConfigMap (URL only), PVC, Deployment, Service |
| `scripts/seed-keyvault-secrets.sh` | Out-of-band secret values |

Azure Verified Modules were skipped (Log Analytics-heavy examples, extra providers). Log Analytics and App Gateway WAF stay out of scope.

## Networking / PIP

One Standard static PIP (`pip-torqvoice-<environment>`, default `pip-torqvoice-dev0`) is used for:

- AKS **outbound SNAT** (`load_balancer_profile.outbound_ip_address_ids`) so the cluster does **not** mint a second managed outbound IP
- Inbound: app LoadBalancer (dev0 / bringup) **or** nginx Ingress (TLS)

## Single-node + RWO (accepted risk)

One system node. Uploads use a 8 GiB **ReadWriteOnce** Azure Disk PVC. Node failure or drain means downtime; the disk cannot attach to a second node until it is released. No HA Postgres. This is an explicit lean-cost trade.

## FinOps (Switzerland North, ballpark)

Rough **CHF/USD ~$90–110/month** for this layout: AKS Free control plane, 1× B2s, Flexible Server B1ms + 32 GiB, one public IP, 8 GiB disk, Key Vault + tfstate Storage (pennies). Traffic, snapshots, and Let's Encrypt retries are extra. **Set an Azure Budget + alert** on `rg-torqvoice-dev0` (and the tfstate RG) before any approved apply; this root does not create a budget resource.

TLS add-ons (nginx, cert-manager) share the same B2s — tight on 4 GiB RAM.

## Next steps (human)

1. `az login`; install [kubelogin](https://github.com/Azure/kubelogin).
2. Fill `bootstrap/terraform.tfvars` (`subscription_id`).
3. After approval: apply bootstrap; copy `backend_hcl` → `backend.hcl`; seed Key Vault.
4. Fill `terraform.tfvars` (`subscription_id`, `environment = "dev0"`, `key_vault_name`, `aks_admin_group_object_ids`).
5. `terraform init -backend-config=backend.hcl` then `terraform plan` in this directory.
6. **Wait for Leo.** Do not apply until approved.
7. After an approved apply: point DNS if TLS; `az aks get-credentials`; confirm ESO synced `secret/torqvoice`.
