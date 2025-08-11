# Example showing how to onboard an AWS account to RSC with DSPM features. 
# The RSC provider will create a CloudFormation stack granting RSC access to the AWS account. 
# See the aws_cnp_account example for how to onboard an AWS account without using a
# CloudFormation stack (Not supported for DSPM).

terraform {
  required_providers {
    polaris = {
      source  = "terraform.rubrik.com/rubrikinc/polaris"
      version = ">=1.0.0"
    }
  }
}

variable "profile" {
  type        = string
  description = "AWS profile."
  default     = "default"
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
    outpost_account_id      = "123456789101"
    outpost_account_profile = var.outpost_profile

    permission_groups = [
      "BASIC",
    ]
  }
}
