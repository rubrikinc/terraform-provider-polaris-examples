terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.8.0-beta.11"
    }
  }
}

variable "profile" {
  type        = string
  description = "AWS profile."
}

# The RSC service account is read from the environment variable
# RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS.
provider "polaris" {}

# Add the AWS account to RSC.
resource "polaris_aws_account" "default" {
  profile = var.profile

  cloud_native_protection {
    regions = [
      "us-east-2",
    ]
  }
}

# Inform RSC about the private container registry.
resource "polaris_aws_private_container_registry" "default" {
  account_id = polaris_aws_account.default.id
  url        = "123456789012.dkr.ecr.us-east-2.amazonaws.com"
}
