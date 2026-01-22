# Configure the AWS Provider
provider "aws" {
  region  = var.region
  profile = "default"
}

# Data sources
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Local values
locals {
  common_tags = merge(var.tags, {
    ManagedBy = "terraform"
    Purpose   = "rubrik-polaris-cloud-cluster"
  })

  # Generate bucket name for S3 module when needed
  generated_bucket_name = "${var.cluster_name}-rubrik-cluster.do.not.delete"

  # Use provided bucket name or the generated name (S3 module will create bucket with this name)
  bucket_name = var.bucket_name != null ? var.bucket_name : local.generated_bucket_name

  # Use provided security groups or create new ones
  security_group_ids = var.security_group_ids != null ? var.security_group_ids : [module.security_group[0].security_group_id]

  # Use provided instance profile or create new one
  instance_profile_name = var.instance_profile_name != null ? var.instance_profile_name : module.iam[0].iam_instance_profile_name
}

# Security Group Module for Rubrik Cluster (only create if not provided)
module "security_group" {
  count = var.security_group_ids == null ? 1 : 0

  source = "./modules/security-group"

  cluster_name                    = var.cluster_name
  vpc_id                          = var.vpc_id
  ingress_allowed_prefix_list_ids = var.ingress_allowed_prefix_list_ids
  egress_allowed_prefix_list_ids  = var.egress_allowed_prefix_list_ids
  ingress_allowed_cidr_blocks     = var.ingress_allowed_cidr_blocks
  egress_allowed_cidr_blocks      = var.egress_allowed_cidr_blocks
  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-rubrik-cluster-sg"
  })
}

# S3 Module for Rubrik (only create if not provided)
module "s3" {
  count = var.bucket_name == null ? 1 : 0

  source = "./modules/s3"

  bucket_name = local.bucket_name
  tags = merge(local.common_tags, {
    Name = local.bucket_name
  })
}

# IAM Module for Rubrik Cluster (only create if not provided)
module "iam" {
  count = var.instance_profile_name == null ? 1 : 0

  source = "./modules/iam"

  cluster_name = var.cluster_name
  bucket_name  = local.bucket_name
  kms_key_arn  = var.kms_key_arn
  tags         = local.common_tags
}


# Add the Servers and Apps feature
# Onboard the AWS account to RSC.
module "account" {
  source    = "./modules/aws_cnp_account"
  name      = var.cloud_account_name
  native_id = data.aws_caller_identity.current.account_id
  regions = [
    var.region,
  ]
  features = {
    SERVERS_AND_APPS : {
      permission_groups = [
        "CLOUD_CLUSTER_ES",
      ],
    }
  }
}

# Wait 60 seconds for the RSC cloud account to be fully provisioned. 
# Without this delay, you may see an error if onboarding CCES too quickly.
resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"

  depends_on = [
    module.account,
    module.iam,
  ]
}

# Create an AWS cloud cluster using RSC
resource "polaris_aws_cloud_cluster" "example" {
  cloud_account_id     = module.account.polaris_aws_cnp_account_id
  region               = var.region
  use_placement_groups = var.use_placement_groups

  cluster_config {
    cluster_name            = var.cluster_name
    admin_email             = var.admin_email
    admin_password          = var.admin_password
    dns_name_servers        = var.dns_name_servers
    dns_search_domains      = var.dns_search_domains
    ntp_servers             = var.ntp_servers
    num_nodes               = var.num_nodes
    bucket_name             = local.bucket_name
    enable_immutability     = var.enable_immutability
    keep_cluster_on_failure = var.keep_cluster_on_failure
  }

  vm_config {
    cdm_version           = var.cdm_version
    instance_type         = var.instance_type
    instance_profile_name = local.instance_profile_name
    vpc_id                = var.vpc_id
    subnet_id             = var.subnet_id
    security_group_ids    = local.security_group_ids
    vm_type               = var.vm_type
  }

  depends_on = [
    time_sleep.wait_30_seconds,
  ]
}
