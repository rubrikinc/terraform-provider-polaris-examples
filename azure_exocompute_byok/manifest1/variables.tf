variable "aks_cluster_name" {
  type        = string
  description = "AKS cluster name."
}

variable "aks_cluster_resource_group" {
  type        = string
  description = "AKS cluster resource group."
}

variable "manifest" {
  type        = string
  description = "RSC Kubernetes manifest."
}
