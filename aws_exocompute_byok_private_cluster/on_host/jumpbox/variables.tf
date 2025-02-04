variable "aws_access_key" {
  description = "AWS access key."
  sensitive   = true
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret access key."
  sensitive   = true
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

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

variable "aws_eks_cluster_region" {
  description = "EKS cluster region."
  type        = string
}

variable "aws_name_prefix" {
  description = "Name prefix for all EKS related resources created in AWS."
  type        = string
  default     = "rubrik-byok8s"
}

variable "jumpbox_instance_type" {
  description = "Jumpbox instance type."
  type        = string
  default     = "t2.micro"
}

variable "jumpbox_public_key" {
  description = "Jumpbox public SSH key."
  type        = string
}

variable "jumpbox_security_group_id" {
  description = "Jumpbox security group ID."
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID."
  type        = string
}

variable "rsc_manifest" {
  description = "RSC generated Kubernetes manifest."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}
