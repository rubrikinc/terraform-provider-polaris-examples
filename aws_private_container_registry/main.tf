# Example showing how to set up a Private Container Registry (PCR) for an
# onboarded AWS account.
#
# See the aws_exocompute_byok_cluster example for how to onboard an AWS account
# with a Bring-Your-Own-Kubernetes (BYOK) cluster, also referred to as Customer
# Managed Exocompute.

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
  description = "RSC cloud account ID of the AWS account hosting the Exocompute."
}

variable "native_id" {
  type        = string
  description = "AWS account ID of the AWS account that will pull images from the RSC container registry."
}

variable "pcr_url" {
  type        = string
  description = "Private container registry URL."
}

provider "polaris" {}

resource "polaris_aws_private_container_registry" "registry" {
  account_id = var.cloud_account_id
  native_id  = var.native_id
  url        = var.pcr_url
}
