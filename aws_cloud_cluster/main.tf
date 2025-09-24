terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.1.7"
    }
  }
}

# Onboard the AWS account to RSC.
module "account" {
  source = "../aws_cnp_account"
  features = {
    SERVERS_AND_APPS : {
      permission_groups = [
        "CLOUD_CLUSTER_ES",
      ],
    }
  }
  name      = var.name
  native_id = var.native_id
  regions = [
    var.region,
  ]
}

# Wait 30 seconds for the RSC cloud account to be fully provisioned. 
# Without this delay, you may see an error if onboarding CCES too quickly.
resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
  depends_on = [
    module.account,
  ]
}

# Create an AWS cloud cluster using RSC.
resource "polaris_aws_cloud_cluster" "cces" {
  cloud_account_id     = module.account.polaris_aws_cnp_account_id
  region               = var.region
  use_placement_groups = true
  cluster_config {
    cluster_name            = var.cluster_name
    admin_email             = var.admin_email
    admin_password          = "RubrikGoForward!"
    dns_name_servers        = ["169.254.169.253"]
    dns_search_domains      = var.dns_search_domains
    ntp_servers             = ["169.254.169.123"]
    num_nodes               = 1
    bucket_name             = var.bucket_name
    enable_immutability     = true
    keep_cluster_on_failure = false
  }
  # VM config items should already exist in AWS.
  vm_config {
    cdm_version           = "9.4.0-p2-30507"
    instance_type         = "M6I_2XLARGE"
    instance_profile_name = var.instance_profile_name
    vpc_id                = var.vpc_id
    subnet_id             = var.subnet_id
    security_group_ids    = var.security_group_ids
    vm_type               = "EXTRA_DENSE"
  }
  depends_on = [
    time_sleep.wait_30_seconds,
  ]
}
