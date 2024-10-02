# Example showing how to create an exocompute configuration using another
# account's exocompute resources for an Azure subscription already onboarded.
#
# Use the azure example to onboard an account with the CLOUD_NATIVE_PROTECTION
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
  description = "RSC cloud account ID of the subscription."
}

variable "host_cloud_account_id" {
  type        = string
  description = "Shared exocompute host RSC cloud account id."
}

provider "polaris" {}

resource "polaris_azure_exocompute" "shared_exocompute" {
  cloud_account_id      = var.cloud_account_id
  host_cloud_account_id = var.host_cloud_account_id
}
