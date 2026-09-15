variable "subscription_id" {
  type        = string
  description = "Azure subscription ID. Required by azurerm 4.x."
}

variable "location" {
  type        = string
  description = "Azure region. This stack is pinned to Switzerland North."
  default     = "switzerlandnorth"

  validation {
    condition     = var.location == "switzerlandnorth"
    error_message = "This Torqvoice stack must be deployed in switzerlandnorth only."
  }
}

variable "environment" {
  type        = string
  description = <<-EOT
    Environment slug used in Azure resource names (rg/aks/vnet/pip/...) and
    force-merged into tags.environment. First bring-up is "dev0" (HTTP
    LoadBalancer allowed). The prod TLS gate applies only when this value is
    literally "prod" — input tags.environment cannot override it.

    Sticky after the first apply: changing this slug renames (destroy +
    create) rg/aks/vnet/pip and related identities. A shared tfstate key is
    OK only while this is the sole workload (dev0). Before a second
    environment the backend key MUST include this slug, and KV secret names
    and/or the vault must be env-prefixed (see README).
  EOT
  default     = "dev0"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,10}[a-z0-9])?$", var.environment))
    error_message = "environment must be a 1-12 character lowercase slug (e.g. dev0, bringup, prod)."
  }

  validation {
    condition     = var.environment != "prod" || (var.enable_tls && trimspace(var.hostname) != "")
    error_message = "environment = \"prod\" requires enable_tls = true and a non-empty hostname. Plain HTTP is only allowed when environment is not prod (use dev0 or bringup)."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for the workload stack. Empty: rg-torqvoice-<environment>."
  default     = ""
}

variable "key_vault_resource_group_name" {
  type        = string
  description = "Resource group of the bootstrap Key Vault (default: tfstate RG)."
  default     = "rg-torqvoice-tfstate"
}

variable "key_vault_name" {
  type        = string
  description = "Existing Key Vault from bootstrap/. Secret values are never written by this root."
}

variable "aks_name" {
  type        = string
  description = "AKS cluster name. Empty: aks-torqvoice-<environment>."
  default     = ""
}

variable "aks_dns_prefix" {
  type        = string
  description = "Base DNS prefix for the AKS API server. Terraform appends a 4-character suffix."
  default     = "torqvoice"
}

variable "aks_admin_group_object_ids" {
  type        = list(string)
  description = <<-EOT
    Optional Entra ID group object IDs granted AKS Cluster Admin via
    azure_active_directory_role_based_access_control.admin_group_object_ids.
    Local kube accounts are disabled; humans use `az aks get-credentials` +
    kubelogin. Not required when aks_admin_user_object_ids is set. At least
    one of the two lists must be non-empty so a named human is in IaC even
    if the apply identity differs. The applying principal always also gets
    Azure Kubernetes Service RBAC Cluster Admin (see identity.tf).
  EOT
  default     = []
}

variable "aks_admin_user_object_ids" {
  type        = list(string)
  description = <<-EOT
    Optional Entra ID *user* object IDs granted Azure Kubernetes Service
    RBAC Cluster Admin on the AKS cluster (direct assignment; no group).
    Use this when there is no Entra admin group. Get the signed-in user:
      az ad signed-in-user show --query id -o tsv
    At least one of aks_admin_group_object_ids or this list must be
    non-empty. Duplicate assignment is skipped when an ID matches the
    current az login principal (already assigned in identity.tf).
    Applied IDs appear in Terraform state as role-assignment principal_id
    (expected; keep real IDs out of git — tfvars is gitignored).
  EOT
  default     = []
}

variable "aks_node_vm_size" {
  type        = string
  description = "VM size for the single AKS node pool."
  default     = "Standard_B2s"
}

variable "aks_node_count" {
  type        = number
  description = "Node count for the single AKS node pool."
  default     = 1

  validation {
    condition     = var.aks_node_count == 1
    error_message = "This lean stack is limited to a single AKS node."
  }
}

variable "postgres_server_name" {
  type        = string
  description = "PostgreSQL Flexible Server name. Leave empty to use psql-torqvoice-<environment>-<4-char>."
  default     = ""
}

variable "postgres_administrator_login" {
  type        = string
  description = "PostgreSQL administrator login (not a secret; password lives in Key Vault)."
  default     = "torqvoice"
}

variable "postgres_database_name" {
  type        = string
  description = "Application database name."
  default     = "torqvoice"
}

variable "postgres_sku_name" {
  type        = string
  description = "PostgreSQL Flexible Server SKU."
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  type        = number
  description = "PostgreSQL storage in MiB (32768 = 32 GiB)."
  default     = 32768
}

variable "postgres_version" {
  type        = string
  description = "PostgreSQL major version."
  default     = "16"
}

variable "postgres_password_wo_version" {
  type        = number
  description = "Bump this after rotating postgres-admin-password in Key Vault so azurerm sends administrator_password_wo again. The password itself is never in state."
  default     = 1
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the shared AKS + PostgreSQL virtual network."
  default     = ["10.60.0.0/16"]
}

variable "aks_subnet_prefix" {
  type        = string
  description = "Subnet for the AKS node pool (Azure CNI)."
  default     = "10.60.0.0/22"
}

variable "postgres_subnet_prefix" {
  type        = string
  description = "Delegated subnet for PostgreSQL Flexible Server."
  default     = "10.60.4.0/24"
}

variable "k8s_service_cidr" {
  type        = string
  description = "Kubernetes service CIDR. Must not overlap the VNet."
  default     = "10.61.0.0/16"
}

variable "k8s_dns_service_ip" {
  type        = string
  description = "kube-dns service IP inside k8s_service_cidr."
  default     = "10.61.0.10"
}

variable "torqvoice_image" {
  type        = string
  description = <<-EOT
    Pinned Torqvoice image. Must be a digest (@sha256:...) or an immutable
    semver tag (v1.2.3). :latest is rejected.

    Default is the public index digest of ghcr.io/torqvoice/torqvoice:latest
    resolved on 2026-09-15. Bump with:
      curl -sI -H "Accept: application/vnd.oci.image.index.v1+json" \
        https://ghcr.io/v2/torqvoice/torqvoice/manifests/<tag> | grep -i docker-content-digest
    or: crane digest ghcr.io/torqvoice/torqvoice:<tag>
  EOT
  default     = "ghcr.io/torqvoice/torqvoice@sha256:6efeb6b22b16e2666ccfc39a85ab102e1dd6ae0492d4896dd2cdc8f72557abad"

  validation {
    condition = (
      !endswith(var.torqvoice_image, ":latest")
      && (
        can(regex("@sha256:[a-f0-9]{64}$", var.torqvoice_image))
        || can(regex(":[vV]?[0-9]+\\.[0-9]+\\.[0-9]+([.-][0-9A-Za-z]+)*$", var.torqvoice_image))
      )
    )
    error_message = "Pin torqvoice_image to a digest (@sha256:64-hex) or immutable semver tag. :latest is not allowed."
  }
}

variable "image_pull_secret_name" {
  type        = string
  default     = ""
  description = <<-EOT
    Optional dockerconfigjson Secret name in namespace torqvoice (created by
    ESO from Key Vault, never by Terraform data). Set when the image is private.
  EOT
}

variable "enable_tls" {
  type        = bool
  default     = false
  description = <<-EOT
    When true, install ingress-nginx + cert-manager and an Ingress with
    Let's Encrypt (HTTP-01). Requires hostname and letsencrypt_email.
    App Gateway WAF is intentionally not used (cost).
  EOT
}

variable "hostname" {
  type        = string
  default     = ""
  description = "Public FQDN for Ingress/TLS (e.g. workshop.example.com). Required when enable_tls is true."
}

variable "letsencrypt_email" {
  type        = string
  default     = ""
  description = "ACME contact email. Required when enable_tls is true."
}

variable "app_url" {
  type        = string
  default     = ""
  description = "Override NEXT_PUBLIC_APP_URL. Empty: https://hostname when TLS is on, otherwise http://<pip> (bringup only)."
}

variable "tags" {
  type        = map(string)
  description = <<-EOT
    Extra tags merged onto Azure resources. tags.environment is always
    overwritten with var.environment (default "dev0") — it is not a second
    TLS switch. The prod HTTP gate reads only var.environment.
  EOT
  default = {
    app         = "torqvoice"
    environment = "dev0"
    managed-by  = "terraform"
  }
}

variable "ingress_nginx_chart_version" {
  type        = string
  default     = "4.15.1"
  description = "Pinned ingress-nginx Helm chart version."
}

variable "cert_manager_chart_version" {
  type        = string
  default     = "v1.21.2"
  description = "Pinned cert-manager Helm chart version."
}

variable "external_secrets_chart_version" {
  type        = string
  default     = "2.10.0"
  description = "Pinned external-secrets Helm chart version."
}
