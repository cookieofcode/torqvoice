resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.external_secrets_chart_version
  namespace        = "external-secrets"
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = "external-secrets"
        annotations = {
          "azure.workload.identity/client-id" = azurerm_user_assigned_identity.eso.client_id
        }
      }
      podLabels = {
        "azure.workload.identity/use" = "true"
      }
    })
  ]

  depends_on = [
    azurerm_kubernetes_cluster.this,
    azurerm_federated_identity_credential.eso,
    azurerm_role_assignment.eso_kv_secrets_user,
    azurerm_role_assignment.current_user_aks_rbac_admin,
  ]
}

# ClusterSecretStore + ExternalSecret: names and templates only (no secret values).
resource "helm_release" "app_secrets" {
  name      = "torqvoice-secrets"
  chart     = "${path.module}/charts/app-secrets"
  namespace = kubernetes_namespace_v1.torqvoice.metadata[0].name
  wait      = true
  timeout   = 300

  values = [
    yamlencode({
      vaultUrl   = data.azurerm_key_vault.this.vault_uri
      tenantId   = data.azurerm_client_config.current.tenant_id
      dbUser     = var.postgres_administrator_login
      dbHost     = azurerm_postgresql_flexible_server.this.fqdn
      dbName     = var.postgres_database_name
      kvPassword = local.kv_secret_postgres_admin
      kvAuth     = local.kv_secret_better_auth
    })
  ]

  depends_on = [
    helm_release.external_secrets,
    kubernetes_namespace_v1.torqvoice,
  ]
}

resource "helm_release" "ingress_nginx" {
  count = local.tls_enabled ? 1 : 0

  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.ingress_nginx_chart_version
  namespace        = "ingress-nginx"
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      controller = {
        replicaCount = 1
        service = {
          loadBalancerIP = azurerm_public_ip.app.ip_address
          # Azure Standard LB HTTP-probes `/` unless this is set; nginx 404s `/`
          # so backends go unhealthy and HTTP-01 / 80/443 time out.
          annotations = {
            "service.beta.kubernetes.io/azure-load-balancer-resource-group"            = azurerm_resource_group.this.name
            "service.beta.kubernetes.io/azure-pip-name"                                = azurerm_public_ip.app.name
            "service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path" = "/healthz"
          }
        }
        resources = {
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
        }
      }
    })
  ]

  depends_on = [
    azurerm_kubernetes_cluster.this,
    azurerm_role_assignment.current_user_aks_rbac_admin,
    azurerm_role_assignment.aks_kubelet_network,
  ]
}

resource "helm_release" "cert_manager" {
  count = local.tls_enabled ? 1 : 0

  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_chart_version
  namespace        = "cert-manager"
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      crds = {
        enabled = true
      }
      replicaCount = 1
    })
  ]

  depends_on = [
    azurerm_kubernetes_cluster.this,
    azurerm_role_assignment.current_user_aks_rbac_admin,
  ]
}

resource "helm_release" "letsencrypt_issuer" {
  count = local.tls_enabled ? 1 : 0

  name      = "letsencrypt-issuer"
  chart     = "${path.module}/charts/letsencrypt-issuer"
  namespace = "cert-manager"
  wait      = true
  timeout   = 300

  values = [
    yamlencode({
      email = var.letsencrypt_email
    })
  ]

  depends_on = [helm_release.cert_manager]
}
