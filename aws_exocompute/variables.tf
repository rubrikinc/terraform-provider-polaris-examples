locals {
  uuid_null  = "00000000-0000-0000-0000-000000000000"
  uuid_regex = "^(?i)[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
}

variable "cloud_account_id" {
  description = "RSC cloud account ID of the AWS account hosting Exocompute."
  type        = string

  validation {
    condition     = var.cloud_account_id != local.uuid_null
    error_message = "The RSC cloud account ID cannot be the null UUID."
  }
  validation {
    condition     = can(regex(local.uuid_regex, var.cloud_account_id))
    error_message = "The RSC cloud account ID must be a valid UUID."
  }
}

variable "region" {
  description = "AWS region to run Exocompute in."
  type        = string
}

variable "subnet1_id" {
  description = "AWS subnet 1 ID."
  type        = string
}

variable "subnet2_id" {
  description = "AWS subnet 2 ID."
  type        = string
}

variable "vpc_id" {
  description = "AWS VPC ID."
  type        = string
}

# Note, if the module rubrikinc/polaris-cloud-native-exocompute-networking/aws
# is being used to create the VPC resources, then both security groups must be
# specified.

variable "cluster_security_group_id" {
  description = "AWS cluster / control plane security group ID."
  type        = string
  default     = null
}

variable "node_security_group_id" {
  description = "AWS node / worker security group ID."
  type        = string
  default     = null
}
