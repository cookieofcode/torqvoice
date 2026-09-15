variable "subscription_id" {
  type        = string
  description = "Azure subscription ID. Required by azurerm 4.x (or export ARM_SUBSCRIPTION_ID and still set this to the same value)."
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

variable "resource_group_name" {
  type        = string
  description = "Resource group for the lean production stack."
  default     = "rg-torqvoice-prod"
}

variable "aks_name" {
  type        = string
  description = "AKS cluster name."
  default     = "aks-torqvoice-prod"
}

variable "aks_dns_prefix" {
  type        = string
  description = "Base DNS prefix for the AKS API server. Terraform appends a 4-character suffix so the FQDN is unique."
  default     = "torqvoice-prod"
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
  description = "PostgreSQL Flexible Server name. Must be globally unique (lowercase, hyphens). Leave empty to append a random suffix to psql-torqvoice."
  default     = ""
}

variable "postgres_administrator_login" {
  type        = string
  description = "PostgreSQL administrator login (not a secret; password is generated)."
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
  description = "PostgreSQL major version (matches the Docker Compose image)."
  default     = "16"
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
  description = "Container image for the Torqvoice workload."
  default     = "ghcr.io/torqvoice/torqvoice:latest"
}

variable "better_auth_secret" {
  type        = string
  sensitive   = true
  default     = ""
  description = <<-EOT
    BETTER_AUTH_SECRET for the Torqvoice process (session signing, and the
    integrations vault when INTEGRATIONS_ENCRYPTION_KEY is unset).

    Generate with: openssl rand -hex 32

    Leave empty to let Terraform create a random 64-character secret (also
    exposed as a sensitive output). Keep this value stable after first apply:
    rotating it signs everyone out and, without INTEGRATIONS_ENCRYPTION_KEY,
    makes stored integration tokens unreadable.
  EOT
}

variable "app_url" {
  type        = string
  default     = ""
  description = <<-EOT
    NEXT_PUBLIC_APP_URL. Leave empty to use http://<static public IP> from the
    first-bring-up LoadBalancer.

    TODO: HTTPS — set this to https://<your-hostname> after TLS is in front of
    the service (ingress or Application Gateway). TLS is out of scope here.
  EOT
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to Azure resources."
  default = {
    app         = "torqvoice"
    environment = "prod"
    managed-by  = "terraform"
  }
}
