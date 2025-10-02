terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.70.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.13.1"
    }
  }
}

# Lookup the current AWS region.
data "aws_region" "current" {}

# Onboard the AWS account to RSC with the Exocompute feature.
module "account" {
  source = "../aws_cnp_account"

  features = {
    EXOCOMPUTE = {
      permission_groups = [
        "BASIC",
        "RSC_MANAGED_CLUSTER",
      ]
    },
  }

  name      = var.name
  native_id = var.native_id

  regions = [
    data.aws_region.current.name,
  ]

  tags = var.tags
}

# Give RSC some time to finalize the AWS account onboarding before attempting
# to create the exocompute configuration.
resource "time_sleep" "wait_for_rsc" {
  create_duration = "15s"

  depends_on = [
    module.account
  ]
}

# Create an Exocompute configuration.
resource "polaris_aws_exocompute" "exocompute" {
  account_id                = module.account.cloud_account_id
  cluster_security_group_id = var.cluster_security_group_id
  node_security_group_id    = var.node_security_group_id
  region                    = data.aws_region.current.name
  vpc_id                    = var.vpc_id

  subnets = [
    var.subnet1,
    var.subnet2,
  ]

  depends_on = [
    time_sleep.wait_for_rsc
  ]
}
