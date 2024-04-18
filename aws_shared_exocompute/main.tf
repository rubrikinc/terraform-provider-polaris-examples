# Example showing how to onboard an AWS account and create an Exocompute
# configuration for the account using an existing account and its Exocompute
# configuration. The RSC provider will create a CloudFormation stack granting
# RSC access to the AWS account.
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

variable "profile" {
  type        = string
  description = "AWS profile."
}

variable "host_account_id" {
  type        = string
  description = "Shared exocompute host RSC account id."
}

provider "polaris" {}

resource "polaris_aws_account" "account" {
  profile = var.profile

  cloud_native_protection {
    regions = [
      "us-east-2",
    ]
  }
}

resource "polaris_aws_exocompute" "shared_exocompute" {
  account_id      = polaris_aws_account.account.id
  host_account_id = var.host_account_id
}
