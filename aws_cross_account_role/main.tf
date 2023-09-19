terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.7.0"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Path to the RSC service account file."
}

variable "role_arn" {
  type        = string
  description = "Role ARN for the cross account role."
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the AWS account identified by the role ARN to RSC. The provider will
# assume the role and create a CloudFormation stack granting RSC access to the
# account.
resource "polaris_aws_account" "account" {
  assume_role = var.role_arn

  cloud_native_protection {
    regions = [
      "us-east-2",
    ]
  }
}
