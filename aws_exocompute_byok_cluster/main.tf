data "aws_region" "current" {}

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

  aws_eks_autoscaling_max_size            = var.aws_eks_autoscaling_max_size
  aws_eks_enable_private_endpoint_access  = var.aws_eks_enable_private_endpoint_access
  aws_eks_kubernetes_version              = var.aws_eks_kubernetes_version
  aws_eks_master_node_role_arn            = module.account.aws_eks_master_node_role_arn
  aws_eks_restrict_public_endpoint_access = var.aws_eks_restrict_public_endpoint_access
  aws_eks_worker_node_instance_profile    = module.account.aws_eks_worker_node_instance_profile
  aws_eks_worker_node_instance_type       = var.aws_eks_worker_node_instance_type
  aws_exocompute_public_subnet_cidr       = var.aws_exocompute_public_subnet_cidr
  aws_exocompute_subnet_1_cidr            = var.aws_exocompute_subnet_1_cidr
  aws_exocompute_subnet_2_cidr            = var.aws_exocompute_subnet_2_cidr
  aws_exocompute_vpc_cidr                 = var.aws_exocompute_vpc_cidr
  aws_name_prefix                         = var.aws_name_prefix
  rsc_account_id                          = module.account.rsc_account_id
  rsc_deployment_ips                      = var.rsc_deployment_ips
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
  region     = data.aws_region.current.name

  depends_on = [
    time_sleep.wait_for_rsc
  ]
}

resource "polaris_aws_exocompute_cluster_attachment" "cluster" {
  exocompute_id = polaris_aws_exocompute.exocompute.id
  cluster_name  = module.cluster.aws_eks_cluster_name
}

# Select one of the two modules below to deploy the K8s resources from the RSC
# K8s manifest to the EKS cluster.

# Deploy K8s resource from the manifest using kubectl.
module "manifest" {
  source = "./manifest1"

  eks_cluster_name   = module.cluster.aws_eks_cluster_name
  eks_cluster_region = data.aws_region.current.name
  manifest           = polaris_aws_exocompute_cluster_attachment.cluster.manifest
}

# # Deploy K8s resource from the manifest using the Kubernetes TF provider.
# module "manifest" {
#   source = "./manifest2"
#
#   eks_cluster_ca_certificate = module.cluster.aws_eks_cluster_ca_certificate
#   eks_cluster_endpoint       = module.cluster.aws_eks_cluster_endpoint
#   eks_cluster_token          = module.cluster.aws_eks_cluster_token
#   manifest                   = polaris_aws_exocompute_cluster_attachment.cluster.manifest
# }
