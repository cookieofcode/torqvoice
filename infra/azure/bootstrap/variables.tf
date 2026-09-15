variable "subscription_id" {
  type        = string
  description = "Azure subscription ID (azurerm 4.x requires this)."
}

variable "location" {
  type        = string
  description = "Azure region. Pinned to Switzerland North, same as the workload root."
  default     = "switzerlandnorth"

  validation {
    condition     = var.location == "switzerlandnorth"
    error_message = "State and Key Vault must live in switzerlandnorth."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for Terraform state and the shared Key Vault."
  default     = "rg-torqvoice-tfstate"
}

variable "storage_account_name" {
  type        = string
  description = <<-EOT
    Globally unique storage account name (3-24 lowercase alphanumeric).
    Leave empty to use sttorqvoicetfstate + a 4-character suffix (check the
    output and copy it into backend.hcl; do not re-roll this root casually).
  EOT
  default     = ""
}

variable "container_name" {
  type        = string
  description = "Blob container for Terraform state."
  default     = "tfstate"
}

variable "key_vault_name" {
  type        = string
  description = <<-EOT
    Globally unique Key Vault name (3-24 chars, alphanumeric and hyphens).
    Leave empty to use kv-tvtf-<suffix>.
  EOT
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags for bootstrap resources."
  default = {
    app         = "torqvoice"
    component   = "tfstate"
    environment = "bootstrap"
    managed-by  = "terraform"
  }
}
