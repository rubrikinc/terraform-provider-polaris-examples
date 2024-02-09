# AWS account and RSC features.
aws_account_id         = 123456789012
aws_account_name       = "Test AWS"
aws_regions_to_protect = ["us-east-2"]

rsc_features    = [
  {
    name = "CLOUD_NATIVE_PROTECTION"
    permission_groups = ["BASIC"]
  },
  {
    name = "EXOCOMPUTE"
    permission_groups = ["BASIC"]
  }
]

# Exocompute cluster.
aws_eks_autoscaling_max_size      = 2
aws_eks_worker_node_instance_type = "t2.small"
aws_exocompute_public_subnet_cidr = "172.31.0.0/20"
aws_exocompute_subnet_1_cidr      = "172.31.16.0/20"
aws_exocompute_subnet_2_cidr      = "172.31.32.0/20"
aws_exocompute_vpc_cidr           = "172.31.0.0/16"

# Private container registry.
rsc_private_registry_url = "123456789012.dkr.ecr.us-east-2.amazonaws.com/terraform-test"
