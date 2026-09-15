terraform {
  required_version = ">= 1.11.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.2.0, < 5.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.16.0, < 3.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.32.0, < 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }

  # Partial config — no access keys. Copy backend.hcl.example → backend.hcl
  # (gitignored) from bootstrap outputs, then:
  #   terraform init -backend-config=backend.hcl
  # Azure AD via `az login` (use_azuread_auth = true). For fmt/validate only:
  #   terraform init -backend=false
  backend "azurerm" {}
}
