# Example showing how to onboard a new AWS account using MFA to RSC. The RSC
# provider will create a CloudFormation stack granting RSC access to the AWS
# account.
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
  default     = "default"
  description = "Name of temporary profile or default for environment variables."
}

provider "polaris" {}

resource "polaris_aws_account" "account" {
  profile = var.profile

  cloud_native_protection {
    permission_groups = [
      "BASIC",
    ]

    regions = [
      "us-east-2",
    ]
  }
}
