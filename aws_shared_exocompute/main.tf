# Example showing how to create an exocompute configuration using another
# account's exocompute resources for an AWS account already onboarded.
#
# Use the aws_cnp_account example to onboard an account with the
# CLOUD_NATIVE_PROTECTION feature.

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

variable "host_account_id" {
  type        = string
  description = "RSC cloud account ID of the shared exocompute host."
}

provider "polaris" {}

resource "polaris_aws_exocompute" "shared_exocompute" {
  account_id      = var.cloud_account_id
  host_account_id = var.host_account_id
}
