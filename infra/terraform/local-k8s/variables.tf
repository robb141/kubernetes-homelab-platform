variable "kubeconfig_path" {
  description = "Path to the kubeconfig file Terraform should use."
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context Terraform should target."
  type        = string
  default     = "docker-desktop"
}

variable "namespace_name" {
  description = "Name of the Kubernetes namespace managed by Terraform."
  type        = string
  default     = "platform-dev"
}

variable "environment" {
  description = "Environment label applied to the namespace."
  type        = string
  default     = "dev"
}

variable "resource_quota" {
  description = "Resource limits applied to the development namespace."
  type = object({
    requests_cpu    = string
    requests_memory = string
    limits_cpu      = string
    limits_memory   = string
    pods            = string
  })

  default = {
    requests_cpu    = "2"
    requests_memory = "2Gi"
    limits_cpu      = "4"
    limits_memory   = "4Gi"
    pods            = "20"
  }
}

variable "container_defaults" {
  description = "Default requests and limits assigned to containers that omit them."
  type = object({
    request_cpu    = string
    request_memory = string
    limit_cpu      = string
    limit_memory   = string
  })

  default = {
    request_cpu    = "100m"
    request_memory = "128Mi"
    limit_cpu      = "500m"
    limit_memory   = "512Mi"
  }
}

variable "staging_namespace_name" {
  description = "Name of the staging Kubernetes namespace."
  type        = string
  default     = "platform-staging"
}

variable "staging_resource_quota" {
  description = "Resource limits applied to the staging namespace."
  type = object({
    requests_cpu    = string
    requests_memory = string
    limits_cpu      = string
    limits_memory   = string
    pods            = string
  })

  default = {
    requests_cpu    = "1"
    requests_memory = "1Gi"
    limits_cpu      = "2"
    limits_memory   = "2Gi"
    pods            = "10"
  }
}

variable "staging_container_defaults" {
  description = "Default requests and limits assigned to staging containers."
  type = object({
    request_cpu    = string
    request_memory = string
    limit_cpu      = string
    limit_memory   = string
  })

  default = {
    request_cpu    = "50m"
    request_memory = "64Mi"
    limit_cpu      = "250m"
    limit_memory   = "256Mi"
  }
}

variable "monitoring_namespace_name" {
  description = "Name of the Kubernetes namespace used for monitoring tools."
  type        = string
  default     = "monitoring"
}
