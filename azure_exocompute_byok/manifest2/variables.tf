variable "aks_host" {
  type        = string
  description = "AKS kube config host."
}

variable "aks_cluster_ca_certificate" {
  type        = string
  description = "AKS kube config cluster CA certificate."
}

variable "aks_client_certificate" {
  type        = string
  description = "AKS kube config client certificate."
}

variable "aks_client_key" {
  type        = string
  description = "AKS kube config client key."
}

variable "manifest" {
  type        = string
  description = "RSC Kubernetes manifest."
}
