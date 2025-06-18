# Example showing how to onboard a new AWS account using MFA to RSC. The RSC
# provider will create a CloudFormation stack granting RSC access to the AWS
# account.

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
