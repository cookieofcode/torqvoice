provider "azurerm" {
  subscription_id = var.subscription_id

  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

# Local kube certs are disabled on the cluster. Auth is Entra ID via kubelogin
# (Azure CLI session). Client keys are never copied into Terraform-managed
# Kubernetes Secrets. Residual: azurerm may still persist a kube_config blob
# on the cluster resource; with local_account_disabled it should not contain
# client keys. We only read the cluster CA (not a credential) when present.
provider "kubernetes" {
  host                   = "https://${azurerm_kubernetes_cluster.this.fqdn}"
  cluster_ca_certificate = local.cluster_ca_certificate

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--login", "azurecli",
      "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630",
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = "https://${azurerm_kubernetes_cluster.this.fqdn}"
    cluster_ca_certificate = local.cluster_ca_certificate

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args = [
        "get-token",
        "--login", "azurecli",
        "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630",
      ]
    }
  }
}
