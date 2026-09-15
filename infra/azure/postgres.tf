# Password is read ephemerally from Key Vault at apply (not stored in state)
# and sent with administrator_password_wo (write-only; not in state or plan).
# Seed the vault first: scripts/seed-keyvault-secrets.sh
# azurerm has no "password from Key Vault resource ID" for Flexible Server;
# this is the supported pattern that keeps the value out of state.
ephemeral "azurerm_key_vault_secret" "postgres_admin" {
  name         = local.kv_secret_postgres_admin
  key_vault_id = data.azurerm_key_vault.this.id
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                              = local.postgres_server_name
  resource_group_name               = azurerm_resource_group.this.name
  location                          = azurerm_resource_group.this.location
  version                           = var.postgres_version
  sku_name                          = var.postgres_sku_name
  storage_mb                        = var.postgres_storage_mb
  administrator_login               = var.postgres_administrator_login
  administrator_password_wo         = ephemeral.azurerm_key_vault_secret.postgres_admin.value
  administrator_password_wo_version = var.postgres_password_wo_version
  delegated_subnet_id               = azurerm_subnet.postgres.id
  private_dns_zone_id               = azurerm_private_dns_zone.postgres.id
  public_network_access_enabled     = false
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  auto_grow_enabled                 = false
  tags                              = var.tags

  # high_availability omitted: Disabled (lean / cost-controlled).
  authentication {
    password_auth_enabled         = true
    active_directory_auth_enabled = false
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_database" "torqvoice" {
  name      = var.postgres_database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
