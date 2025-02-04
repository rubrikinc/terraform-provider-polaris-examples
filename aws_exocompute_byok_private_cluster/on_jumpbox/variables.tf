variable "aws_eks_cluster_ca_certificate" {
  description = "EKS cluster CA certificate."
  type        = string
}

variable "aws_eks_cluster_endpoint" {
  description = "EKS cluster endpoint."
  type        = string
}

variable "aws_eks_cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "jumpbox_data" {
  description = "Jumpbox data bucket."
  type        = string
}
