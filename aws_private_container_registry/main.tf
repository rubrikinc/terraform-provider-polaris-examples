# Example showing how to set up a private container registry for an AWS account
# already onboarded.
#
# See the aws_exocompute_byok_cluster example for how to onboard an AWS account
# with a Bring-Your-Own-Kubernetes cluster.
#
# Note, when private container registry has been turned on for an RSC account,
# it can only be turned off again by contacting Rubrik support.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.8.0"
    }
  }
}

variable "cloud_account_id" {
  type        = string
  description = "RSC cloud account ID of the account."
}

variable "pcr_url" {
  type        = string
  description = "Private container registry URL."
}

provider "polaris" {}

resource "polaris_aws_private_container_registry" "registry" {
  account_id = var.cloud_account_id
  url        = var.pcr_url
}
