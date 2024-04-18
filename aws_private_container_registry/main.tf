# Example showing how to set up a private container registry for an existing
# AWS cloud account in RSC.
#
# See the aws_exocompute_byok_cluster example for how to onboard an AWS account
# with a Bring-Your-Own-Kubernetes cluster. The RSC service account is read from
# the RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS environment variable.
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
  description = "RSC cloud account ID."
}

provider "polaris" {}

resource "polaris_aws_private_container_registry" "registry" {
  account_id = var.cloud_account_id
  url        = "123456789012.dkr.ecr.us-east-2.amazonaws.com"
}
