# Example showing how to onboard an AWS account to RSC. The RSC provider will
# create a CloudFormation stack granting RSC access to the AWS account. See the
# aws_cnp_account example for how to onboard an AWS account without using a
# CloudFormation stack.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.0.0"
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
    permission_groups = [
      "BASIC",
    ]

    regions = [
      "us-east-2",
    ]
  }
}
