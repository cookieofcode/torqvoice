# Offline copy of the workload TLS / environment gate and AKS viewer skip
# (no azurerm, no ephemeral KV). scripts/check-env-gates.sh fails if these
# expressions drift from ../../variables.tf, ../../locals.tf, ../../identity.tf.

variable "environment" {
  type    = string
  default = "dev0"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,10}[a-z0-9])?$", var.environment))
    error_message = "environment must be a 1-12 character lowercase slug (e.g. dev0, bringup, prod)."
  }

  validation {
    condition     = var.environment != "prod" || (var.enable_tls && trimspace(var.hostname) != "")
    error_message = "environment = \"prod\" requires enable_tls = true and a non-empty hostname. Plain HTTP is only allowed when environment is not prod (use dev0 or bringup)."
  }
}

variable "enable_tls" {
  type    = bool
  default = false
}

variable "hostname" {
  type    = string
  default = ""
}

variable "tags" {
  type = map(string)
  default = {
    app         = "torqvoice"
    environment = "dev0"
    managed-by  = "terraform"
  }
}

# Fixture Entra object IDs only — not real identities or secrets.
# identity.tf skips viewers that match the apply principal or a named admin.
variable "aks_admin_user_object_ids" {
  type    = list(string)
  default = []
}

variable "aks_viewer_user_object_ids" {
  type    = list(string)
  default = []
}

locals {
  tags        = merge(var.tags, { environment = var.environment })
  tls_enabled = var.enable_tls && trimspace(var.hostname) != ""
  is_prod     = var.environment == "prod"

  # Same expressions as kubernetes_service_v1.torqvoice (PR #11): the
  # kubernetes provider rejects "" for load_balancer_ip. Fixture IP is
  # TEST-NET-1 (RFC 5737), not a real Azure PIP.
  service_type     = local.tls_enabled ? "ClusterIP" : "LoadBalancer"
  load_balancer_ip = local.tls_enabled ? null : "192.0.2.10"

  # Stand-in for data.azurerm_client_config.current.object_id (no Azure here).
  apply_principal_object_id = "00000000-0000-0000-0000-0000000000c3"

  aks_viewer_user_object_ids = toset([
    for object_id in var.aks_viewer_user_object_ids : object_id
    if object_id != local.apply_principal_object_id
    && !contains(var.aks_admin_user_object_ids, object_id)
  ])
}

check "prod_http_forbidden" {
  assert {
    condition     = !local.is_prod || local.tls_enabled
    error_message = "environment = \"prod\" requires enable_tls and a non-empty hostname (Let's Encrypt + nginx Ingress). Plain HTTP is for non-prod (dev0 / bringup) only."
  }
}

check "tags_environment_matches_var" {
  assert {
    condition     = local.tags["environment"] == var.environment
    error_message = "tags.environment must equal var.environment (force-merged). Input tags cannot override the environment slug or the TLS gate."
  }
}

resource "terraform_data" "gate" {
  input = {
    is_prod          = local.is_prod
    tls_enabled      = local.tls_enabled
    tags_env         = local.tags["environment"]
    service_type     = local.service_type
    load_balancer_ip = local.load_balancer_ip
    viewer_ids       = join(",", sort(tolist(local.aks_viewer_user_object_ids)))
    viewer_count     = length(local.aks_viewer_user_object_ids)
  }
}
