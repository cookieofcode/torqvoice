data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "this" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}

locals {
  postgres_server_name = trimspace(var.postgres_server_name) != "" ? var.postgres_server_name : "psql-torqvoice-${random_string.unique.result}"

  tls_enabled = var.enable_tls && trimspace(var.hostname) != ""

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
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Hard gate: prod + HTTP must not plan. Variable validation covers tags;
# this catches enable_tls=true without hostname.
check "prod_http_forbidden" {
  assert {
    condition     = try(var.tags["environment"], "") != "prod" || local.tls_enabled
    error_message = "tags.environment = \"prod\" requires enable_tls and a non-empty hostname (Let's Encrypt + nginx Ingress). Plain HTTP is bringup only."
  }
}

check "tls_requires_acme_email" {
  assert {
    condition     = !var.enable_tls || trimspace(var.letsencrypt_email) != ""
    error_message = "enable_tls requires letsencrypt_email for the Let's Encrypt ClusterIssuer."
  }
}
