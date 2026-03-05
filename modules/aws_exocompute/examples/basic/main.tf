terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.0.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.5.0"
    }
  }
}

variable "account_id" {
  description = "AWS account ID."
  type        = string
}

variable "account_name" {
  description = "AWS account name."
  type        = string
}

variable "tags" {
  description = "Tags to apply to AWS resources created."
  type        = map(string)
  default = {
    Example    = "basic"
    Module     = "aws_exocompute"
    Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}

data "aws_region" "current" {}

# Create the VPC and subnets in AWS.
module "vpc" {
  source = "../../modules/exocompute_vpc"

  name             = "aws_exocompute"
  public_cidr      = "172.22.0.0/24"
  subnet1_cidr     = "172.22.1.0/24"
  subnet2_cidr     = "172.22.2.0/24"
  pod_subnet1_cidr = "172.22.10.0/24"
  pod_subnet2_cidr = "172.22.11.0/24"
  vpc_cidr         = "172.22.0.0/16"

  tags = var.tags
}

# Onboard the AWS account to RSC with the Exocompute feature.
module "aws_iam_account" {
  source = "../../../aws_iam_account"

  account_id   = var.account_id
  account_name = var.account_name

  features = {
    EXOCOMPUTE = {
      permission_groups = [
        "BASIC",
        "RSC_MANAGED_CLUSTER",
      ]
    },
  }

  regions = [
    data.aws_region.current.region,
  ]

  tags = var.tags
}

# Create the exocompute configuration.
module "aws_exocompute" {
  source = "../.."

  cloud_account_id          = module.aws_iam_account.cloud_account_id
  cluster_access            = "EKS_CLUSTER_ACCESS_TYPE_PRIVATE"
  cluster_security_group_id = module.vpc.cluster_security_group_id
  node_security_group_id    = module.vpc.node_security_group_id
  region                    = data.aws_region.current.region
  subnet1_id                = module.vpc.subnet1_id
  subnet2_id                = module.vpc.subnet2_id
  pod_subnet1_id            = module.vpc.pod_subnet1_id
  pod_subnet2_id            = module.vpc.pod_subnet2_id
  vpc_id                    = module.vpc.vpc_id
}
