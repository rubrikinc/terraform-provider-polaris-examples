variable "eks_cluster_ca_certificate" {
  type        = string
  description = "EKS cluster CA certificate."
}

variable "eks_cluster_endpoint" {
  type        = string
  description = "EKS cluster endpoint."
}

variable "eks_cluster_token" {
  type        = string
  description = "EKS cluster token."
}

variable "manifest" {
  type        = string
  description = "RSC Kubernetes manifest."
}
