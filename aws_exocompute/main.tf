# Example showing how to create an exocompute configuration for an AWS account
# already onboarded.
#
# Use the aws_cnp_account example to onboard an account with the EXOCOMPUTE
# feature.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.10.0-beta.4"
    }
  }
}

variable "cloud_account_id" {
  type        = string
  description = "RSC cloud account ID of the account."
}

variable "region" {
  type        = string
  description = "AWS exocompute region."
  default     = "us-east-2"
}

variable "subnet1" {
  type        = string
  description = "AWS subnet 1."
}

variable "subnet2" {
  type        = string
  description = "AWS subnet 2."
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID."
}

provider "polaris" {}

resource "polaris_aws_exocompute" "exocompute" {
  account_id = var.cloud_account_id
  region     = var.region
  vpc_id     = var.vpc_id

  subnets = [
    var.subnet1,
    var.subnet2,
  ]
}
