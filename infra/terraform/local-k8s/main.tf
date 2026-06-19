module "platform_namespace" {
  source = "./modules/platform-namespace"

  namespace_name     = var.namespace_name
  environment        = var.environment
  resource_quota     = var.resource_quota
  container_defaults = var.container_defaults
}

module "platform_staging" {
  source = "./modules/platform-namespace"

  namespace_name     = var.staging_namespace_name
  environment        = "staging"
  resource_quota     = var.staging_resource_quota
  container_defaults = var.staging_container_defaults
}

moved {
  from = kubernetes_namespace.platform_dev
  to   = module.platform_namespace.kubernetes_namespace.this
}

moved {
  from = kubernetes_resource_quota_v1.platform_dev
  to   = module.platform_namespace.kubernetes_resource_quota_v1.this
}

moved {
  from = kubernetes_limit_range_v1.platform_dev
  to   = module.platform_namespace.kubernetes_limit_range_v1.this
}
