# Offline copy of the workload TLS / environment gate (no azurerm, no
# ephemeral KV). scripts/check-env-gates.sh fails if these expressions
# drift from ../../variables.tf and ../../locals.tf.

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

locals {
  tags        = merge(var.tags, { environment = var.environment })
  tls_enabled = var.enable_tls && trimspace(var.hostname) != ""
  is_prod     = var.environment == "prod"
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
    is_prod     = local.is_prod
    tls_enabled = local.tls_enabled
    tags_env    = local.tags["environment"]
  }
}
