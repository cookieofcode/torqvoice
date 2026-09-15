resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.aks_name
  location                  = azurerm_resource_group.this.location
  resource_group_name       = azurerm_resource_group.this.name
  dns_prefix                = "${var.aks_dns_prefix}-${random_string.unique.result}"
  sku_tier                  = "Free"
  azure_policy_enabled      = false
  local_account_disabled    = true
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = var.aks_admin_group_object_ids
    tenant_id              = data.azurerm_client_config.current.tenant_id
  }

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
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = var.k8s_service_cidr
    dns_service_ip    = var.k8s_dns_service_ip
    outbound_type     = "loadBalancer"

    # Reuse the single Standard PIP for SNAT so AKS does not mint a second
    # managed outbound IP. Same PIP is used inbound (app LB or ingress).
    load_balancer_profile {
      outbound_ip_address_ids = [azurerm_public_ip.app.id]
    }
  }

  tags = var.tags

  depends_on = [azurerm_role_assignment.aks_uami_network]

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      default_node_pool[0].orchestrator_version,
    ]

    precondition {
      condition     = length(var.aks_admin_group_object_ids) > 0
      error_message = "aks_admin_group_object_ids must contain at least one Entra ID group. Local kube admin certs are disabled."
    }

    precondition {
      condition     = !var.enable_tls || (trimspace(var.hostname) != "" && trimspace(var.letsencrypt_email) != "")
      error_message = "enable_tls requires hostname and letsencrypt_email."
    }
  }
}

resource "azurerm_role_assignment" "aks_kubelet_network" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
