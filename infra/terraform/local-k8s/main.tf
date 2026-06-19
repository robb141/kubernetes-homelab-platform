resource "kubernetes_namespace" "platform_dev" {
  metadata {
    name = var.namespace_name

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "homelab.dev/environment"      = "dev"
    }
  }
}
