resource "kubernetes_ingress_v1" "torqvoice" {
  count = local.tls_enabled ? 1 : 0

  metadata {
    name      = "torqvoice"
    namespace = kubernetes_namespace_v1.torqvoice.metadata[0].name
    labels    = local.k8s_labels
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.hostname]
      secret_name = "torqvoice-tls"
    }

    rule {
      host = var.hostname

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.torqvoice.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.ingress_nginx,
    helm_release.letsencrypt_issuer,
  ]
}
