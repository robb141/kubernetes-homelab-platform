output "namespace_name" {
  description = "Name of the managed namespace."
  value       = kubernetes_namespace.this.metadata[0].name
}

output "resource_quota_name" {
  description = "Name of the namespace ResourceQuota."
  value       = kubernetes_resource_quota_v1.this.metadata[0].name
}

output "limit_range_name" {
  description = "Name of the namespace LimitRange."
  value       = kubernetes_limit_range_v1.this.metadata[0].name
}
