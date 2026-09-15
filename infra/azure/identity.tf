resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks-torqvoice"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "eso" {
  name                = "id-eso-torqvoice"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_role_assignment" "aks_uami_network" {
  scope                            = azurerm_resource_group.this.id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_user_assigned_identity.aks.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "eso_kv_secrets_user" {
  scope                            = data.azurerm_key_vault.this.id
  role_definition_name             = "Key Vault Secrets User"
  principal_id                     = azurerm_user_assigned_identity.eso.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_federated_identity_credential" "eso" {
  name                = "eso-torqvoice"
  resource_group_name = azurerm_resource_group.this.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.this.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.eso.id
  subject             = "system:serviceaccount:external-secrets:external-secrets"
}

# The az login principal that runs apply needs this to helm-install ESO/ingress.
resource "azurerm_role_assignment" "current_user_aks_rbac_admin" {
  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}
