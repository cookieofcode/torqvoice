resource "azurerm_user_assigned_identity" "aks" {
  name                = local.aks_identity_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_user_assigned_identity" "eso" {
  name                = local.eso_identity_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
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
  name                = local.eso_federated_name
  resource_group_name = azurerm_resource_group.this.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.this.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.eso.id
  subject             = "system:serviceaccount:external-secrets:external-secrets"
}

# The az login principal that runs apply needs this to helm-install ESO/ingress.
# This is enough for bringup *as that identity*; named humans still belong in
# aks_admin_user_object_ids or aks_admin_group_object_ids (cluster precondition).
resource "azurerm_role_assignment" "current_user_aks_rbac_admin" {
  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Direct Entra users (no group). Skip IDs that match the apply principal so Azure
# does not see two assignments for the same principal + role + scope.
resource "azurerm_role_assignment" "aks_admin_users" {
  for_each = toset([
    for object_id in var.aks_admin_user_object_ids : object_id
    if object_id != data.azurerm_client_config.current.object_id
  ])

  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = each.value
}

# Read-only troubleshooting viewers: workload RG + AKS namespaces, not Cluster
# Admin and not Key Vault secrets. Skip IDs that already have Cluster Admin
# (named admins or the apply principal) so Azure does not see overlapping
# assignments for the same principal.
locals {
  aks_viewer_user_object_ids = toset([
    for object_id in var.aks_viewer_user_object_ids : object_id
    if object_id != data.azurerm_client_config.current.object_id
    && !contains(var.aks_admin_user_object_ids, object_id)
  ])
}

resource "azurerm_role_assignment" "aks_viewer_users_rg_reader" {
  for_each = local.aks_viewer_user_object_ids

  scope                = azurerm_resource_group.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "aks_viewer_users_cluster_user" {
  for_each = local.aks_viewer_user_object_ids

  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "aks_viewer_users_rbac_reader" {
  for_each = local.aks_viewer_user_object_ids

  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = each.value
}
