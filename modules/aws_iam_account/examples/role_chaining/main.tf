terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.0.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.6.3"
    }
  }
}

variable "role_chaining_account_id" {
  type        = string
  description = "AWS account ID for the role-chaining account."
}

variable "role_chaining_account_name" {
  type        = string
  description = "AWS account name for the role-chaining account."
}

variable "role_chained_account_id" {
  type        = string
  description = "AWS account ID for the role-chained account."
}

variable "role_chained_account_name" {
  type        = string
  description = "AWS account name for the role-chained account."
}

variable "tags" {
  description = "Tags to apply to AWS resources created."
  type        = map(string)
  default = {
    Example    = "role_chaining"
    Module     = "aws_iam_account"
    Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}

provider "aws" {
  alias   = "role_chaining_provider"
  profile = "role-chaining"
}

provider "aws" {
  alias   = "role_chained_provider"
  profile = "role-chained"
}

module "role_chaining_account" {
  source    = "../.."
  providers = {
    aws = aws.role_chaining_provider,
  }

  account_id   = var.role_chaining_account_id
  account_name = var.role_chaining_account_name

  features = {
    ROLE_CHAINING = {
      permission_groups = [
        "BASIC",
      ]
    },
  }

  regions = [
    "us-east-2",
  ]

  tags = var.tags
}

module "role_chained_account" {
  source    = "../.."
  providers = {
    aws = aws.role_chained_provider,
  }

  account_id               = var.role_chained_account_id
  account_name             = var.role_chained_account_name
  role_chaining_account_id = module.role_chaining_account.cloud_account_id

  features = {
    CLOUD_DISCOVERY = {
      permission_groups = [
        "BASIC",
      ]
    },
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC",
      ]
    },
    EXOCOMPUTE = {
      permission_groups = [
        "BASIC",
        "RSC_MANAGED_CLUSTER",
      ]
    },
  }

  regions = [
    "us-east-2",
  ]

  tags = var.tags
}
