# Example showing how to onboard an AWS account to RSC. The RSC provider will
# create a CloudFormation stack granting RSC access to the AWS account.
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

  cloud_native_protection {
    regions = [
      "us-east-2",
    ]
  }
}
