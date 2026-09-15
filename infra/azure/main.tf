resource "random_string" "unique" {
  length  = 4
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "random_password" "postgres" {
  length           = 32
  special          = true
  override_special = "_-"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
}

resource "random_password" "better_auth" {
  length  = 64
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
