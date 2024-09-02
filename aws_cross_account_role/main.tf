# Example showing how to onboard an AWS account, identified by the role ARN,
# to RSC. The provider will assume the role and create a CloudFormation stack
# granting RSC access to the account.
#
# The AWS default profile and the profile's default region are read from the
# standard ~/.aws/credentials and ~/.aws/config files. The RSC service account
# is read from the RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS environment
# variable.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.8.0"
    }
  }
}

variable "role_arn" {
  type        = string
  description = "Role ARN for the cross account role."
}

provider "polaris" {}

resource "polaris_aws_account" "account" {
  assume_role = var.role_arn

  cloud_native_protection {
    permission_groups = [
      "BASIC",
    ]

    regions = [
      "us-east-2",
    ]
  }
}
