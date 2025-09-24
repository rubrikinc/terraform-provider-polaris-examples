# Variables for the AWS cloud cluster example.

variable "name" {
  type        = string
  description = "AWS account name."
}

variable "native_id" {
  type        = string
  description = "AWS account ID."
}

variable "region" {
  type        = string
  description = "AWS region."
}

variable "admin_email" {
  type        = string
  description = "Admin email address."
}

variable "cluster_name" {
  type        = string
  description = "Cloud cluster name."
}

variable "bucket_name" {
  type        = string
  description = "AWS S3 bucket name."
}

variable "dns_search_domains" {
  type        = set(string)
  description = "DNS search domains."
}

variable "instance_profile_name" {
  type        = string
  description = "AWS EC2 instance profile name."
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID."
}

variable "subnet_id" {
  type        = string
  description = "AWS subnet ID."
}

variable "security_group_ids" {
  type        = set(string)
  description = "AWS security group IDs."
}
