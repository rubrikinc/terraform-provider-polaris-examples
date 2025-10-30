locals {
  uuid_null  = "00000000-0000-0000-0000-000000000000"
  uuid_regex = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
}

variable "cloud_account_id" {
  description = "RSC cloud account ID of the AWS account hosting Exocompute."
  type        = string

  validation {
    condition     = var.cloud_account_id != local.uuid_null && can(regex(local.uuid_regex, var.cloud_account_id))
    error_message = "Cloud account ID must be a valid, lower case, UUID."
  }
}

variable "region" {
  description = "AWS region to run Exocompute in."
  type        = string

  validation {
    condition     = var.region != null && contains(data.aws_regions.regions.names, var.region)
    error_message = "Region must be a valid AWS region."
  }
}

variable "subnet1_id" {
  description = "AWS subnet 1 ID."
  type        = string

  validation {
    condition     = can(regex("^subnet-[a-f0-9]{17}$", var.subnet1_id))
    error_message = "Subnet1 ID must be a valid AWS subnet ID."
  }
}

variable "subnet2_id" {
  description = "AWS subnet 2 ID."
  type        = string

  validation {
    condition     = can(regex("^subnet-[a-f0-9]{17}$", var.subnet2_id))
    error_message = "Subnet2 ID must be a valid AWS subnet ID."
  }
}

variable "vpc_id" {
  description = "AWS VPC ID."
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-f0-9]{8}(?:[a-f0-9]{9})?$", var.vpc_id))
    error_message = "VPC ID must be a valid AWS VPC ID."
  }
}

# Note, if the module rubrikinc/polaris-cloud-native-exocompute-networking/aws
# is being used to create the VPC resources, then both security groups must be
# specified.

variable "cluster_security_group_id" {
  description = "AWS cluster / control plane security group ID."
  type        = string
  default     = null

  validation {
    condition     = var.cluster_security_group_id == null || can(regex("^sg-[a-f0-9]{17}$", var.cluster_security_group_id))
    error_message = "Cluster security group ID must be a valid AWS security group ID."
  }
}

variable "node_security_group_id" {
  description = "AWS node / worker security group ID."
  type        = string
  default     = null

  validation {
    condition     = var.node_security_group_id == null || can(regex("^sg-[a-f0-9]{17}$", var.node_security_group_id))
    error_message = "Node security group ID must be a valid AWS security group ID."
  }
}
