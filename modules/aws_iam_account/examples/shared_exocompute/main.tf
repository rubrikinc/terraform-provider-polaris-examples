terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.0.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.2.0"
    }
  }
}

variable "account_id" {
  type        = string
  description = "AWS account ID."
}

variable "account_name" {
  type        = string
  description = "AWS account name."
}

variable "exocompute_host_id" {
  type        = string
  description = "RSC cloud account ID (UUID) of the AWS account hosting Exocompute."
}

variable "tags" {
  description = "Tags to apply to AWS resources created."
  type        = map(string)
  default = {
    Example    = "shared_exocompute"
    Module     = "aws_iam_account"
    Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}

module "aws_iam_account" {
  source = "../.."

  account_id         = var.account_id
  account_name       = var.account_name
  exocompute_host_id = var.exocompute_host_id

  features = {
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC"
      ]
    },
  }

  regions = [
    "us-east-2",
    "us-west-2",
  ]

  tags = var.tags
}
