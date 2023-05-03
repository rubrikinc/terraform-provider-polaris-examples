# Point Terraform to the RSC provider.
terraform {
  required_providers {
    polaris = {
      source = "rubrikinc/polaris"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Path to the RSC service account file."
}

variable "profile" {
  type        = string
  description = "AWS profile."
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the AWS account to RSC. Access key and secret key are read from
# ~/.aws/credentials. The default region is read from ~/.aws/config. RSC will
# authenticate to AWS using an IAM role setup in a CloudFormation stack.
resource "polaris_aws_account" "default" {
  profile = var.profile

  # Set the permissions resource argument to update to have Terraform generate
  # a diff on permissions changes.
  permissions = "update"

  cloud_native_protection {
    regions = [
      "us-east-2",
    ]
  }
}
