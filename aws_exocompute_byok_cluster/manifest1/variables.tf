variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name."
}

variable "eks_cluster_region" {
  type        = string
  description = "EKS cluster region."
}

variable "manifest" {
  type        = string
  description = "RSC Kubernetes manifest."
}
