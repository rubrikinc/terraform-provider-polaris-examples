# Example showing how to onboard an AWS account to RSC with DSPM features. 
# The RSC provider will create a CloudFormation stack granting RSC access to
# the AWS account. See modules/aws_iam_account for how to onboard an AWS account
# without using a CloudFormation stack (Not supported for DSPM).

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
  default     = "default"
}

variable "outpost_account_id" {
  type        = string
  description = "value of the account id of the outpost account."
  default     = "123456789101"
}

variable "outpost_profile" {
  type        = string
  description = "AWS outpost profile."
  default     = "outpost"
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

  dspm {
    permission_groups = [
      "BASIC",
    ]

    regions = [
      "us-east-2",
    ]
  }

  outpost {
    outpost_account_id      = var.outpost_account_id
    outpost_account_profile = var.outpost_profile

    permission_groups = [
      "BASIC",
    ]
  }
}
