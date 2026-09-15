data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "this" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}

locals {
  # tags.environment always matches var.environment (single source of truth).
  tags = merge(var.tags, {
    environment = var.environment
  })

  resource_group_name = trimspace(var.resource_group_name) != "" ? var.resource_group_name : "rg-torqvoice-${var.environment}"
  aks_name            = trimspace(var.aks_name) != "" ? var.aks_name : "aks-torqvoice-${var.environment}"
  vnet_name           = "vnet-torqvoice-${var.environment}"
  pip_name            = "pip-torqvoice-${var.environment}"
  aks_identity_name   = "id-aks-torqvoice-${var.environment}"
  eso_identity_name   = "id-eso-torqvoice-${var.environment}"
  eso_federated_name  = "eso-torqvoice-${var.environment}"

  postgres_server_name = trimspace(var.postgres_server_name) != "" ? var.postgres_server_name : "psql-torqvoice-${var.environment}-${random_string.unique.result}"

  tls_enabled = var.enable_tls && trimspace(var.hostname) != ""

  # Prod TLS gate applies only when environment or tag is literally "prod".
  is_prod = var.environment == "prod" || try(var.tags["environment"], "") == "prod"

  app_url = trimspace(var.app_url) != "" ? var.app_url : (
    local.tls_enabled ? "https://${var.hostname}" : "http://${azurerm_public_ip.app.ip_address}"
  )

  k8s_labels = {
    app     = "torqvoice"
    part-of = "torqvoice"
  }

  kv_secret_postgres_admin = "postgres-admin-password"
  kv_secret_better_auth    = "better-auth-secret"

  # Cluster CA only (not client key material). Empty until the cluster exists.
  cluster_ca_certificate = try(base64decode(azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate), "")
}

resource "random_string" "unique" {
  length  = 4
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

# Hard gate: prod + HTTP must not plan. Variable validation covers tags and
# var.environment; this catches enable_tls=true without hostname.
check "prod_http_forbidden" {
  assert {
    condition     = !local.is_prod || local.tls_enabled
    error_message = "environment/tags.environment = \"prod\" requires enable_tls and a non-empty hostname (Let's Encrypt + nginx Ingress). Plain HTTP is for non-prod (dev0 / bringup) only."
  }
}

check "tls_requires_acme_email" {
  assert {
    condition     = !var.enable_tls || trimspace(var.letsencrypt_email) != ""
    error_message = "enable_tls requires letsencrypt_email for the Let's Encrypt ClusterIssuer."
  }
}
