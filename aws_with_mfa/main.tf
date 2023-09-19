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

variable "profile" {
  type        = string
  default     = "default"
  description = "Name of temporary profile or default for environment variables."
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

  cloud_native_protection {
    regions = [
      "us-east-2",
    ]
  }
}
