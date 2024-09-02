# Example showing how to onboard a new AWS account to RSC and have Terraform
# generate a diff on permissions changes. The RSC provider will create a
# CloudFormation stack granting RSC access to the AWS account.
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

provider "polaris" {}

resource "polaris_aws_account" "account" {
  profile = var.profile

  # Set the permissions resource argument to update to have Terraform generate
  # a diff on permissions changes.
  permissions = "update"

  cloud_native_protection {
    permission_groups = [
      "BASIC",
    ]

    regions = [
      "us-east-2",
    ]
  }
}
