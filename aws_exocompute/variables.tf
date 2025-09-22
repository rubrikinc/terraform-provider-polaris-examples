variable "name" {
  description = "AWS account name."
  type        = string
}

variable "native_id" {
  description = "AWS account ID."
  type        = string
}

variable "subnet1" {
  description = "AWS subnet 1 ID."
  type        = string
}

variable "subnet2" {
  description = "AWS subnet 2 ID."
  type        = string
}

variable "vpc_id" {
  description = "AWS VPC ID."
  type        = string
}

variable "tags" {
  description = "Tags to apply to AWS resources created."
  type        = map(string)
  default = {
    Environment = "test"
    Example     = "aws_exocompute"
    Module      = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
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
