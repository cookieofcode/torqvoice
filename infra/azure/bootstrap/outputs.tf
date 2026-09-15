output "resource_group_name" {
  description = "Resource group holding tfstate storage and Key Vault."
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Copy into backend.hcl (storage accounts are globally unique)."
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Blob container for Terraform state."
  value       = azurerm_storage_container.tfstate.name
}

output "key_vault_name" {
  description = "Key Vault for application secrets (values are set out-of-band)."
  value       = azurerm_key_vault.this.name
}

output "key_vault_uri" {
  description = "Key Vault URI."
  value       = azurerm_key_vault.this.vault_uri
}

output "backend_hcl" {
  description = "Ready-to-paste backend.hcl contents (fill subscription_id)."
  value       = <<-EOT
    resource_group_name  = "${azurerm_resource_group.tfstate.name}"
    storage_account_name = "${azurerm_storage_account.tfstate.name}"
    container_name       = "${azurerm_storage_container.tfstate.name}"
    key                  = "torqvoice.switzerlandnorth.tfstate"
    use_azuread_auth     = true
    subscription_id      = "<subscription-id>"
  EOT
}
