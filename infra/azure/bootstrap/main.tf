data "azurerm_client_config" "current" {}

resource "random_string" "unique" {
  length  = 4
  lower   = true
  upper   = false
  numeric = true
  special = false
}

locals {
  storage_account_name = trimspace(var.storage_account_name) != "" ? var.storage_account_name : "sttorqvoicetfstate${random_string.unique.result}"
  key_vault_name       = trimspace(var.key_vault_name) != "" ? var.key_vault_name : "kv-tvtf-${random_string.unique.result}"
}

resource "azurerm_resource_group" "tfstate" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "tfstate" {
  name                            = local.storage_account_name
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  local_user_enabled              = false
  tags                            = var.tags

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }
  }
}

# Azure AD is the only auth path (access keys disabled). The identity that
# runs terraform init/plan/apply of the workload root needs this role.
resource "azurerm_role_assignment" "tfstate_blob" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"

  depends_on = [azurerm_role_assignment.tfstate_blob]
}

resource "azurerm_key_vault" "this" {
  name                          = local.key_vault_name
  location                      = azurerm_resource_group.tfstate.location
  resource_group_name           = azurerm_resource_group.tfstate.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  purge_protection_enabled      = false
  soft_delete_retention_days    = 7
  public_network_access_enabled = true
  tags                          = var.tags
}

# Data-plane access for seed scripts and for ephemeral KV reads at apply.
# Terraform never writes secret *values* into this vault.
resource "azurerm_role_assignment" "kv_secrets_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
