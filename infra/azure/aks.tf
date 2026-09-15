resource "azurerm_kubernetes_cluster" "this" {
  name                   = var.aks_name
  location               = azurerm_resource_group.this.location
  resource_group_name    = azurerm_resource_group.this.name
  dns_prefix             = "${var.aks_dns_prefix}-${random_string.unique.result}"
  sku_tier               = "Free"
  azure_policy_enabled   = false
  local_account_disabled = false

  default_node_pool {
    name                         = "system"
    vm_size                      = var.aks_node_vm_size
    node_count                   = var.aks_node_count
    auto_scaling_enabled         = false
    vnet_subnet_id               = azurerm_subnet.aks.id
    os_disk_size_gb              = 64
    os_disk_type                 = "Managed"
    type                         = "VirtualMachineScaleSets"
    max_pods                     = 30
    only_critical_addons_enabled = false
    node_public_ip_enabled       = false
    temporary_name_for_rotation  = "systemtmp"

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = var.k8s_service_cidr
    dns_service_ip    = var.k8s_dns_service_ip
    outbound_type     = "loadBalancer"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      default_node_pool[0].orchestrator_version,
    ]
  }
}

# AKS needs Network Contributor on this RG so it can attach the static PIP and
# manage the Standard Load Balancer in the same VNet.
resource "azurerm_role_assignment" "aks_network" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_kubelet_network" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
