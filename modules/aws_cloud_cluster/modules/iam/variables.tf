# Variables for IAM Module

variable "cluster_name" {
  description = "Name of the cluster for resource naming"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket for IAM policy resources"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for S3 bucket encryption (optional)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}
