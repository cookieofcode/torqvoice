# Azure Terraform — lean Torqvoice (Switzerland North)

Everything-as-Code for a cost-controlled Torqvoice stack in **Switzerland North**. This directory is a Terraform root. Azure and Kubernetes objects for this stack belong here, in git. Do not create or change them in the portal or with one-off `az` / `kubectl` commands.

## WARNING — do not apply without Leo's approval

**Do not run `terraform apply`.** Do not provision, mutate, or destroy Azure resources from this root until Leo has reviewed the plan and explicitly approved apply.

Allowed without that approval:

```bash
az login
az account set --subscription <subscription-id>
cd infra/azure
cp terraform.tfvars.example terraform.tfvars   # then edit subscription_id
terraform init
terraform fmt -recursive
terraform plan
```

`terraform apply`, `terraform destroy`, and any equivalent (`az group create`, portal clicks, etc.) are **out of scope** until Leo approves.

## Layout

| File | What it defines |
| --- | --- |
| `versions.tf` | Terraform `>= 1.6`, azurerm `>= 4.2 < 5`, kubernetes, random |
| `providers.tf` | azurerm (subscription_id required) + kubernetes from AKS kubeconfig |
| `variables.tf` | Region pin, SKUs, secrets, networking |
| `main.tf` | Resource group, random suffix, generated passwords |
| `network.tf` | Shared VNet, AKS subnet, delegated PostgreSQL subnet, private DNS, static PIP |
| `aks.tf` | AKS **Free** tier, one node pool (`Standard_B2s` × 1) |
| `postgres.tf` | Flexible Server **B_Standard_B1ms**, 32 GiB, HA disabled |
| `kubernetes.tf` | Namespace, secret, PVC, Deployment, LoadBalancer Service |
| `k8s/` | Reviewable YAML equivalent (no real secrets) |
| `outputs.tf` | Names, IPs, **sensitive** DB URL and `BETTER_AUTH_SECRET` |
| `terraform.tfvars.example` | Copy to gitignored `terraform.tfvars` |

Azure Verified Modules for AKS and PostgreSQL Flexible Server exist, but their examples pull Log Analytics, extra providers (`azapi`, `modtm`), and heavier SKUs. This root uses hand-written `azurerm` resources so the lean layout stays reviewable and cost-controlled. Log Analytics, App Gateway WAF, and multi-AZ HA are **out of scope**.

## What gets planned (when apply is approved)

```
switzerlandnorth
└── rg-torqvoice-prod
    ├── vnet-torqvoice-prod
    │   ├── snet-aks          (Azure CNI nodes)
    │   └── snet-postgres     (delegated Microsoft.DBforPostgreSQL/flexibleServers)
    ├── privatelink.postgres.database.azure.com  (linked to the VNet)
    ├── pip-torqvoice-prod    (Standard static public IP)
    ├── aks-torqvoice-prod    (sku_tier = Free, 1 × Standard_B2s)
    └── psql-torqvoice-<suffix>  (B_Standard_B1ms, 32 GiB, HA off, VNet injected)
        └── database torqvoice
```

Kubernetes (after the cluster exists):

- Image: `ghcr.io/torqvoice/torqvoice:latest`
- Env: `DATABASE_URL`, `BETTER_AUTH_SECRET`, `NEXT_PUBLIC_APP_URL`
- Service: `LoadBalancer` on port 80 → 3000, bound to the static PIP
- **TODO: HTTPS** — HTTP only for first bring-up

## Secrets

Nothing secret is hardcoded.

| Secret | Source |
| --- | --- |
| PostgreSQL password | `random_password.postgres` (sensitive output) |
| `DATABASE_URL` | Built from that password + Flexible Server FQDN (`sslmode=require`) |
| `BETTER_AUTH_SECRET` | Set `better_auth_secret` in `terraform.tfvars`, **or** leave empty and use the generated sensitive output |

Generate your own Better Auth secret:

```bash
openssl rand -hex 32
```

Keep it stable after first apply. Rotating it signs everyone out. If `INTEGRATIONS_ENCRYPTION_KEY` is unset, the app also derives the integrations vault from this value.

Copy `terraform.tfvars.example` → `terraform.tfvars` (gitignored). Never commit real tfvars or state.

## Next steps (human)

1. Set `subscription_id` in `terraform.tfvars` (azurerm 4.x requires it).
2. `az login` and select that subscription.
3. `terraform init` then `terraform plan` in this directory.
4. **Wait.** Do not apply until Leo approves.
5. After an approved apply: `terraform output app_url`, open HTTP (TLS still a TODO), and store sensitive outputs in your secret store.

Remote state (Azure Storage backend) is not configured yet. Local state is gitignored; agree a backend before any approved apply.
