# Security Group Module for Rubrik Cloud Cluster
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Security Group for Rubrik Cluster
resource "aws_security_group" "rubrik_cluster" {
  name_prefix = "${var.cluster_name}-rubrik-cluster-"
  description = "Security group for Rubrik Cloud Cluster"
  vpc_id      = var.vpc_id

  # Inbound rules for cluster communication
  ingress {
    description     = "HTTPS"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = length(var.ingress_allowed_prefix_list_ids) > 0 ? var.ingress_allowed_prefix_list_ids : null
    cidr_blocks     = length(var.ingress_allowed_cidr_blocks) > 0 ? var.ingress_allowed_cidr_blocks : null
  }

  ingress {
    description     = "SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    prefix_list_ids = length(var.ingress_allowed_prefix_list_ids) > 0 ? var.ingress_allowed_prefix_list_ids : null
    cidr_blocks     = length(var.ingress_allowed_cidr_blocks) > 0 ? var.ingress_allowed_cidr_blocks : null
  }

  ingress {
    description = "Rubrik cluster communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Outbound rules
  egress {
    description     = "All outbound traffic"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    prefix_list_ids = length(var.egress_allowed_prefix_list_ids) > 0 ? var.egress_allowed_prefix_list_ids : null
    cidr_blocks     = length(var.egress_allowed_cidr_blocks) > 0 ? var.egress_allowed_cidr_blocks : null
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
