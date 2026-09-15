terraform {
  required_version = ">= 1.11.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.2.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }

  # Local state on purpose: this root *creates* the remote backend.
  # After an approved apply, optionally migrate this state into the new
  # container with key=bootstrap.tfstate (see parent README).
}

provider "azurerm" {
  subscription_id = var.subscription_id
  # Required when the tfstate account has shared_access_key_enabled = false.
  # Without this, create/refresh of the account and container uses shared-key
  # auth and fails with KeyBasedAuthenticationNotPermitted.
  storage_use_azuread = true

  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}
