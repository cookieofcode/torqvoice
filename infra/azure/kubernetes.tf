resource "kubernetes_namespace_v1" "torqvoice" {
  metadata {
    name   = "torqvoice"
    labels = local.k8s_labels
  }

  depends_on = [
    azurerm_kubernetes_cluster.this,
    azurerm_role_assignment.aks_network,
    azurerm_role_assignment.aks_kubelet_network,
  ]
}

resource "kubernetes_secret_v1" "torqvoice" {
  metadata {
    name      = "torqvoice"
    namespace = kubernetes_namespace_v1.torqvoice.metadata[0].name
    labels    = local.k8s_labels
  }

  data = {
    DATABASE_URL        = local.database_url
    BETTER_AUTH_SECRET  = local.better_auth_secret
    NEXT_PUBLIC_APP_URL = local.app_url
  }

  type = "Opaque"
}

resource "kubernetes_persistent_volume_claim_v1" "uploads" {
  metadata {
    name      = "torqvoice-uploads"
    namespace = kubernetes_namespace_v1.torqvoice.metadata[0].name
    labels    = local.k8s_labels
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "managed-csi"

    resources {
      requests = {
        storage = "8Gi"
      }
    }
  }

  # Azure Disk CSI uses WaitForFirstConsumer; do not block apply until the pod exists.
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "torqvoice" {
  metadata {
    name      = "torqvoice"
    namespace = kubernetes_namespace_v1.torqvoice.metadata[0].name
    labels    = local.k8s_labels
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = local.k8s_labels.app
      }
    }

    template {
      metadata {
        labels = local.k8s_labels
      }

      spec {
        security_context {
          fs_group = 1001
        }

        container {
          name              = "torqvoice"
          image             = var.torqvoice_image
          image_pull_policy = "Always"

          port {
            name           = "http"
            container_port = 3000
            protocol       = "TCP"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.torqvoice.metadata[0].name
            }
          }

          security_context {
            run_as_non_root = true
            run_as_user     = 1001
            run_as_group    = 1001
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1"
              memory = "1536Mi"
            }
          }

          # init-db.sh runs Prisma migrations before the server listens.
          startup_probe {
            http_get {
              path = "/api/v1/health"
              port = 3000
            }
            period_seconds    = 10
            failure_threshold = 30
          }

          readiness_probe {
            http_get {
              path = "/api/v1/health"
              port = 3000
            }
            period_seconds    = 10
            failure_threshold = 3
          }

          liveness_probe {
            http_get {
              path = "/api/v1/health"
              port = 3000
            }
            period_seconds    = 20
            failure_threshold = 3
          }

          volume_mount {
            name       = "uploads"
            mount_path = "/app/data/uploads"
          }
        }

        volume {
          name = "uploads"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.uploads.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "torqvoice" {
  metadata {
    name      = "torqvoice"
    namespace = kubernetes_namespace_v1.torqvoice.metadata[0].name
    labels    = local.k8s_labels
    annotations = {
      "service.beta.kubernetes.io/azure-load-balancer-resource-group" = azurerm_resource_group.this.name
      "service.beta.kubernetes.io/azure-pip-name"                     = azurerm_public_ip.app.name
      # TODO: HTTPS — terminate TLS at an ingress controller or Application Gateway.
      # This LoadBalancer is HTTP-only for first bring-up.
    }
  }

  spec {
    type             = "LoadBalancer"
    load_balancer_ip = azurerm_public_ip.app.ip_address

    selector = {
      app = local.k8s_labels.app
    }

    port {
      name        = "http"
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }
  }

  depends_on = [
    azurerm_role_assignment.aks_network,
    azurerm_role_assignment.aks_kubelet_network,
  ]
}
