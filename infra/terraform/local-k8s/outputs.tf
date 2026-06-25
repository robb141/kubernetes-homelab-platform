output "namespace_name" {
  description = "Kubernetes namespace created by Terraform."
  value       = module.platform_namespace.namespace_name
}

output "resource_quota_name" {
  description = "ResourceQuota applied to the Kubernetes namespace."
  value       = module.platform_namespace.resource_quota_name
}

output "limit_range_name" {
  description = "LimitRange providing default container resources."
  value       = module.platform_namespace.limit_range_name
}

output "staging_namespace_name" {
  description = "Staging Kubernetes namespace created by Terraform."
  value       = module.platform_staging.namespace_name
}

output "staging_resource_quota_name" {
  description = "ResourceQuota applied to the staging namespace."
  value       = module.platform_staging.resource_quota_name
}

output "staging_limit_range_name" {
  description = "LimitRange providing staging container defaults."
  value       = module.platform_staging.limit_range_name
}

output "monitoring_namespace_name" {
  description = "Kubernetes namespace used for monitoring tools."
  value       = kubernetes_namespace.monitoring.metadata[0].name
}
