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

variable "tags" {
  description = "Tags to apply to AWS resources created."
  type        = map(string)
  default = {
    Example    = "basic"
    Module     = "aws_iam_account"
    Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}

module "aws_iam_account" {
  source = "../.."

  account_id   = var.account_id
  account_name = var.account_name

  features = {
    CLOUD_NATIVE_ARCHIVAL = {
      permission_groups = [
        "BASIC"
      ]
    },
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC"
      ]
    },
    EXOCOMPUTE = {
      permission_groups = [
        "BASIC",
        "RSC_MANAGED_CLUSTER"
      ]
    },
    CLOUD_NATIVE_DYNAMODB_PROTECTION = {
      permission_groups = [
        "BASIC"
      ]
    },
    CLOUD_NATIVE_S3_PROTECTION = {
      permission_groups = [
        "BASIC"
      ]
    },
    RDS_PROTECTION = {
      permission_groups = [
        "BASIC"
      ]
    },
    SERVERS_AND_APPS = {
      permission_groups = [
        "CLOUD_CLUSTER_ES"
      ]
    },
  }

  regions = [
    "us-east-2",
    "us-west-2",
  ]

  tags = var.tags
}
