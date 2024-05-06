# Example showing how to onboard an AWS account and create an Exocompute
# configuration for the account. The RSC provider will create a CloudFormation
# stack granting RSC access to the AWS account.
#
# The AWS profile and the profile's default region are read from the standard
# ~/.aws/credentials and ~/.aws/config files. The RSC service account is read
# from the RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS environment variable.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.8.0"
    }
  }
}

variable "cluster_security_group_id" {
  type        = string
  description = "AWS cluster security group ID."
  default     = null
}

variable "node_security_group_id" {
  type        = string
  description = "AWS node secruity group ID."
  default     = null
}

variable "profile" {
  type        = string
  description = "AWS profile."
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID."
}

variable "subnet1" {
  type        = string
  description = "AWS subnet 1 ID."
}

variable "subnet2" {
  type        = string
  description = "AWS subnet 2 ID."
}

provider "polaris" {}

resource "polaris_aws_account" "account" {
  profile = var.profile

  cloud_native_protection {
    regions = [
      "us-east-2",
    ]
  }

  exocompute {
    regions = [
      "us-east-2",
    ]
  }
}

resource "polaris_aws_exocompute" "exocompute" {
  account_id                = polaris_aws_account.account.id
  cluster_security_group_id = var.cluster_security_group_id
  node_security_group_id    = var.node_security_group_id
  region                    = "us-east-2"
  vpc_id                    = var.vpc_id

  subnets = [
    var.subnet1,
    var.subnet2,
  ]
}
