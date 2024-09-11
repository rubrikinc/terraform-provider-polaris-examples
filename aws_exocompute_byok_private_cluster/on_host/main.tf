# Add AWS account to RSC.
module "account" {
  source = "./account"

  aws_account_id                      = var.aws_account_id
  aws_account_name                    = var.aws_account_name
  aws_ec2_recovery_role_path          = var.aws_ec2_recovery_role_path
  aws_external_id                     = var.aws_external_id
  aws_regions_to_protect              = var.aws_regions_to_protect
  aws_role_path                       = var.aws_role_path
  rsc_cloud_type                      = var.rsc_cloud_type
  rsc_delete_aws_snapshots_on_destroy = var.rsc_delete_aws_snapshots_on_destroy
  rsc_features                        = var.rsc_features
}

# Create EKS cluster.
module "cluster" {
  source = "./eks_cluster"

  aws_eks_autoscaling_max_size           = var.aws_eks_autoscaling_max_size
  aws_eks_access_cidrs                   = var.aws_eks_access_cidrs
  aws_eks_cluster_region                 = var.aws_region
  aws_eks_enable_private_endpoint_access = var.aws_eks_enable_private_endpoint_access
  aws_eks_enable_public_endpoint_access  = var.aws_eks_enable_public_endpoint_access
  aws_eks_version                        = var.aws_eks_kubernetes_version
  aws_eks_master_node_role_arn           = module.account.aws_eks_master_node_role_arn
  aws_eks_worker_node_instance_profile   = module.account.aws_eks_worker_node_instance_profile
  aws_eks_worker_node_instance_type      = var.aws_eks_worker_node_instance_type
  aws_exocompute_public_subnet_cidr      = var.aws_exocompute_public_subnet_cidr
  aws_exocompute_subnet_1_cidr           = var.aws_exocompute_subnet_1_cidr
  aws_exocompute_subnet_2_cidr           = var.aws_exocompute_subnet_2_cidr
  aws_exocompute_vpc_cidr                = var.aws_exocompute_vpc_cidr
  aws_name_prefix                        = var.aws_name_prefix
}

# Give RSC some time to finalize the AWS account addition before attempting to
# onboard the PCR and create the exocompute configuration.
resource "time_sleep" "wait_for_rsc" {
  create_duration = "60s"

  depends_on = [
    module.account
  ]
}

# Take care with this resource as there is no easy way to disable the private
# container registry once it has been enabled.
resource "polaris_aws_private_container_registry" "registry" {
  account_id = module.account.rsc_account_id
  native_id  = var.aws_account_id
  url        = var.rsc_private_registry_url

  depends_on = [
    time_sleep.wait_for_rsc
  ]
}

resource "polaris_aws_exocompute" "exocompute" {
  account_id = module.account.rsc_account_id
  region     = var.aws_region

  depends_on = [
    time_sleep.wait_for_rsc
  ]
}

resource "polaris_aws_exocompute_cluster_attachment" "cluster" {
  exocompute_id = polaris_aws_exocompute.exocompute.id
  cluster_name  = module.cluster.aws_eks_cluster_name
}

# Create a jumpbox in the public subnet of the VPC hosting the EKS cluster.
# The jumpbox will be recreated when the manifest changes.
module "jumpbox" {
  source = "./jumpbox"

  aws_access_key                 = var.aws_access_key
  aws_secret_key                 = var.aws_secret_key
  aws_region                     = var.aws_region
  aws_eks_cluster_ca_certificate = module.cluster.aws_eks_cluster_ca_certificate
  aws_eks_cluster_endpoint       = module.cluster.aws_eks_cluster_endpoint
  aws_eks_cluster_name           = module.cluster.aws_eks_cluster_name
  aws_eks_cluster_region         = var.aws_region
  aws_name_prefix                = var.aws_name_prefix
  jumpbox_public_key             = var.jumpbox_public_key
  jumpbox_security_group_id      = module.cluster.jumpbox_security_group_id
  public_subnet_id               = module.cluster.aws_public_subnet_id
  rsc_manifest                   = polaris_aws_exocompute_cluster_attachment.cluster.manifest
  vpc_id                         = module.cluster.aws_vpc_id
}
