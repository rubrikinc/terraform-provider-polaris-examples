# Example showing how to create an Exocompute configuration, for an already
# onboarded Azure subscription, which uses another Azure subscription's
# Exocompute resources. See the azure example for how to onboard an Azure
# subscription with the CLOUD_NATIVE_PROTECTION feature.

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
  description = "RSC cloud account ID of the Azure subscription."
}

variable "host_cloud_account_id" {
  type        = string
  description = "RSC cloud account ID of the shared exocompute host."
}

provider "polaris" {}

resource "polaris_azure_exocompute" "shared_exocompute" {
  cloud_account_id      = var.cloud_account_id
  host_cloud_account_id = var.host_cloud_account_id
}
