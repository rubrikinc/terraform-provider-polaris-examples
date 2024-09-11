terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  # If public endpoint access is turned off, then private endpoint access must
  # be turned on.
  endpoint_private_access = var.aws_eks_enable_public_endpoint_access ? var.aws_eks_enable_private_endpoint_access : true
}

resource "aws_eks_cluster" "exocompute" {
  name     = "${var.aws_name_prefix}-rubrik-exocompute-${var.aws_eks_cluster_region}"
  role_arn = var.aws_eks_master_node_role_arn
  version  = var.aws_eks_version

  vpc_config {
    endpoint_private_access = local.endpoint_private_access
    endpoint_public_access  = var.aws_eks_enable_public_endpoint_access
    public_access_cidrs     = var.aws_eks_access_cidrs

    security_group_ids = [
      aws_security_group.jumpbox.id,
      aws_security_group.node.id,
    ]

    subnet_ids = [
      aws_subnet.exocompute_subnet_1.id,
      aws_subnet.exocompute_subnet_2.id,
    ]
  }
}

resource "aws_vpc_security_group_ingress_rule" "cluster_allow_node" {
  description = "Allow inbound traffic from worker nodes"

  security_group_id            = aws_eks_cluster.exocompute.vpc_config[0].cluster_security_group_id
  referenced_security_group_id = aws_security_group.node.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "cluster_allow_jumpbox" {
  description = "Allow inbound traffic from jumpbox"

  security_group_id            = aws_eks_cluster.exocompute.vpc_config[0].cluster_security_group_id
  referenced_security_group_id = aws_security_group.jumpbox.id
  ip_protocol                  = "-1"
}
