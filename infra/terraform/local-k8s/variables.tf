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
