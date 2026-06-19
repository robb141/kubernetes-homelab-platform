variable "namespace_name" {
  description = "Name of the Kubernetes namespace."
  type        = string
}

variable "environment" {
  description = "Environment label applied to the namespace."
  type        = string
}

variable "resource_quota" {
  description = "Namespace-wide resource quota."
  type = object({
    requests_cpu    = string
    requests_memory = string
    limits_cpu      = string
    limits_memory   = string
    pods            = string
  })
}

variable "container_defaults" {
  description = "Default requests and limits for containers."
  type = object({
    request_cpu    = string
    request_memory = string
    limit_cpu      = string
    limit_memory   = string
  })
}
