# Example showing how to create an Exocompute configuration, for an already
# onboarded AWS account, which uses another AWS account's Exocompute resources.
# See the aws_cnp_account example for how to onboard an AWS account with the
# CLOUD_NATIVE_PROTECTION feature.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.0.0"
    }
  }
}

variable "cloud_account_id" {
  type        = string
  description = "RSC cloud account ID of the AWS account."
}

variable "host_account_id" {
  type        = string
  description = "RSC cloud account ID of the shared exocompute host."
}

provider "polaris" {}

resource "polaris_aws_exocompute" "shared_exocompute" {
  account_id      = var.cloud_account_id
  host_account_id = var.host_account_id
}
