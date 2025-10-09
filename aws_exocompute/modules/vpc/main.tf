data "aws_region" "current" {}

data "aws_availability_zones" "current" {
  state = "available"

  lifecycle {
    postcondition {
      condition     = length(self.names) > 1
      error_message = "Region must have at least 2 availability zones."
    }
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids   = [aws_route_table.private.id]
  vpc_endpoint_type = "Gateway"

  tags = merge(var.tags, {
    Name = "${var.name}-s3-endpoint"
  })
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.cluster.id,
    aws_security_group.node.id
  ]

  subnet_ids = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]

  tags = merge(var.tags, {
    Name = "${var.name}-ec2-endpoint"
  })
}

resource "aws_vpc_endpoint" "eks" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.eks"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.cluster.id,
    aws_security_group.node.id
  ]

  subnet_ids = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]

  tags = merge(var.tags, {
    Name = "${var.name}-eks-endpoint"
  })
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.cluster.id,
    aws_security_group.node.id
  ]

  subnet_ids = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]

  tags = merge(var.tags, {
    Name = "${var.name}-ecr-api-endpoint"
  })
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.cluster.id,
    aws_security_group.node.id
  ]

  subnet_ids = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]

  tags = merge(var.tags, {
    Name = "${var.name}-ecr-dkr-endpoint"
  })
}

resource "aws_vpc_endpoint" "autoscaling" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.autoscaling"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.cluster.id,
    aws_security_group.node.id
  ]

  subnet_ids = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]

  tags = merge(var.tags, {
    Name = "${var.name}-autoscaling-endpoint"
  })
}

# This endpoint prevents Amazon GuardDuty from creating its own endpoint
# outside of Terraform.
resource "aws_vpc_endpoint" "guardduty_data" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.guardduty-data"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.cluster.id,
    aws_security_group.node.id
  ]

  subnet_ids = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]

  tags = merge(var.tags, {
    Name = "${var.name}-guardduty-data-endpoint"
  })

}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_cidr
  availability_zone       = data.aws_availability_zones.current.names[0]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name}-public-subnet"
  })
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet1_cidr
  availability_zone       = data.aws_availability_zones.current.names[0]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name                                = "${var.name}-subnet1"
    "kubernetes.io/cluster/${var.name}" = "shared"
  })
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet2_cidr
  availability_zone       = data.aws_availability_zones.current.names[1]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name                                = "${var.name}-subnet2"
    "kubernetes.io/cluster/${var.name}" = "shared"
  })
}

resource "aws_eip" "eip" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_nat_gateway" "gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

  tags = merge(var.tags, {
    Name = var.name
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.gateway,
  ]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "${var.name}-public-route-table"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "${var.name}-private-route-table"
  })
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.gateway.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.private.id
}

# EKS cluster security groups.

resource "aws_security_group" "cluster" {
  name   = "${var.name}-cluster"
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "${var.name}-cluster"
  })
}

resource "aws_security_group" "node" {
  name   = "${var.name}-node"
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "${var.name}-node"
  })
}

# Ingress/egress rules for the cluster security group.

resource "aws_vpc_security_group_ingress_rule" "cluster_node_443" {
  description = "Inbound traffic from nodes"

  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.node.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "cluster_node_1025_65535" {
  description = "Outbound traffic to nodes"

  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.node.id

  ip_protocol = "tcp"
  from_port   = 1025
  to_port     = 65535
}

resource "aws_vpc_security_group_egress_rule" "cluster_any_ipv4" {
  description = "Outbound traffic to any IPv4 address"

  security_group_id = aws_security_group.cluster.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Ingress/egress rules for the node security group.

resource "aws_vpc_security_group_ingress_rule" "node_node_all" {
  description = "Inbound traffic from nodes"

  security_group_id            = aws_security_group.node.id
  referenced_security_group_id = aws_security_group.node.id

  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "node_cluster_443" {
  description = "Inbound traffic from cluster"

  security_group_id            = aws_security_group.node.id
  referenced_security_group_id = aws_security_group.cluster.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "node_cluster_1025_65535" {
  description = "Inbound traffic from cluster"

  security_group_id            = aws_security_group.node.id
  referenced_security_group_id = aws_security_group.cluster.id

  ip_protocol = "tcp"
  from_port   = 1025
  to_port     = 65535
}

resource "aws_vpc_security_group_egress_rule" "node_all_ipv4" {
  description = "Outbound traffic from nodes to all IPv4 addresses"

  security_group_id = aws_security_group.node.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
