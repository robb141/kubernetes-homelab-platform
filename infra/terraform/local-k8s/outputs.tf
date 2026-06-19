output "namespace_name" {
  description = "Kubernetes namespace created by Terraform."
  value       = kubernetes_namespace.platform_dev.metadata[0].name
}
