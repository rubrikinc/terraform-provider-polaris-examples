resource "aws_vpc" "rsc_exocompute" {
  cidr_block           = var.aws_exocompute_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Rubrik Exocompute VPC"
  }
}

resource "aws_vpc_endpoint" "rsc_exocompute" {
  vpc_id            = aws_vpc.rsc_exocompute.id
  route_table_ids   = [aws_route_table.rsc_exocompute_private.id]
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "Rubrik Exocompute VPC S3 Endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = aws_vpc.rsc_exocompute.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2"
  vpc_endpoint_type   = "Interface"

  security_group_ids = [
    aws_security_group.cluster.id,
    aws_security_group.worker.id
  ]

  subnet_ids = [
    aws_subnet.rsc_exocompute_subnet_1.id,
    aws_subnet.rsc_exocompute_subnet_2.id
  ]

  tags = {
    Name = "Rubrik Exocompute VPC EC2 Endpoint"
  }
}

resource "aws_vpc_endpoint" "eks" {
  vpc_id              = aws_vpc.rsc_exocompute.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.eks"
  vpc_endpoint_type   = "Interface"

  security_group_ids = [
    aws_security_group.cluster.id,
    aws_security_group.worker.id
  ]
  
  subnet_ids = [
    aws_subnet.rsc_exocompute_subnet_1.id,
    aws_subnet.rsc_exocompute_subnet_2.id
  ]

  tags = {
    Name = "Rubrik Exocompute VPC EKS Endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.rsc_exocompute.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"

  security_group_ids = [
    aws_security_group.cluster.id,
    aws_security_group.worker.id
  ]
  
  subnet_ids = [
    aws_subnet.rsc_exocompute_subnet_1.id,
    aws_subnet.rsc_exocompute_subnet_2.id
  ]

  tags = {
    Name = "Rubrik Exocompute VPC ECR API Endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.rsc_exocompute.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"

  security_group_ids = [
    aws_security_group.cluster.id,
    aws_security_group.worker.id
  ]
  
  subnet_ids = [
    aws_subnet.rsc_exocompute_subnet_1.id,
    aws_subnet.rsc_exocompute_subnet_2.id
  ]

  tags = {
    Name = "Rubrik Exocompute VPC ECR DKR Endpoint"
  }
}

resource "aws_vpc_endpoint" "autoscaling" {
  vpc_id              = aws_vpc.rsc_exocompute.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.autoscaling"
  vpc_endpoint_type   = "Interface"

  security_group_ids = [
    aws_security_group.cluster.id,
    aws_security_group.worker.id
  ]
  
  subnet_ids = [
    aws_subnet.rsc_exocompute_subnet_1.id,
    aws_subnet.rsc_exocompute_subnet_2.id
  ]

  tags = {
    Name = "Rubrik Exocompute VPC Autoscaling Endpoint"
  }
}

resource "aws_subnet" "rsc_exocompute_public" {
  vpc_id                  = aws_vpc.rsc_exocompute.id
  availability_zone       = "${data.aws_region.current.name}a"
  cidr_block              = var.aws_exocompute_public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "Rubrik Exocompute Public Subnet"
  }
}

resource "aws_subnet" "rsc_exocompute_subnet_1" {
  vpc_id                  = aws_vpc.rsc_exocompute.id
  availability_zone       = "${data.aws_region.current.name}a"
  cidr_block              = var.aws_exocompute_subnet_1_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "Rubrik Exocompute Subnet 1"
  }
}

resource "aws_subnet" "rsc_exocompute_subnet_2" {
  vpc_id                  = aws_vpc.rsc_exocompute.id
  availability_zone       = "${data.aws_region.current.name}b"
  cidr_block              = var.aws_exocompute_subnet_2_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "Rubrik Exocompute Subnet 2"
  }
}

resource "aws_eip" "rsc_exocompute_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "Rubrik Exocompute NAT EIP"
  }
}

resource "aws_internet_gateway" "rsc_exocompute" {
  vpc_id = aws_vpc.rsc_exocompute.id

  tags = {
    Name = "Rubrik Exocompute Internet Gateway"
  }
}

resource "aws_nat_gateway" "rsc_exocompute" {
  allocation_id = aws_eip.rsc_exocompute_nat_eip.id
  subnet_id     = aws_subnet.rsc_exocompute_public.id

  tags = {
    Name = "Rubrik Exocompute NAT Gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.rsc_exocompute]
}

resource "aws_route_table" "rsc_exocompute_private" {
  vpc_id = aws_vpc.rsc_exocompute.id

  tags = {
    Name = "Rubrik Exocompute Private Route Table"
  }
}

resource "aws_route_table" "rsc_exocompute_public" {
  vpc_id = aws_vpc.rsc_exocompute.id

  tags = {
    Name = "Rubrik Exocompute Public Route Table"
  }
}

resource "aws_route" "rsc_exocompute_public_internet_gateway" {
  route_table_id         = aws_route_table.rsc_exocompute_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.rsc_exocompute.id
}

resource "aws_route" "rsc_exocompute_private_nat_gateway" {
  route_table_id         = aws_route_table.rsc_exocompute_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.rsc_exocompute.id
}

resource "aws_route_table_association" "rsc_exocompute_public" {
  subnet_id      = aws_subnet.rsc_exocompute_public.id
  route_table_id = aws_route_table.rsc_exocompute_public.id
}

resource "aws_route_table_association" "rsc_exocompute_private_1" {
  subnet_id      = aws_subnet.rsc_exocompute_subnet_1.id
  route_table_id = aws_route_table.rsc_exocompute_private.id
}


resource "aws_route_table_association" "rsc_exocompute_private_2" {
  subnet_id      = aws_subnet.rsc_exocompute_subnet_2.id
  route_table_id = aws_route_table.rsc_exocompute_private.id
}

# EKS cluster security groups.

resource "aws_security_group" "cluster" {
  description = "Security group for EKS cluster control plane"
  name        = "${var.aws_name_prefix}-cluster-security-group"
  vpc_id      = aws_vpc.rsc_exocompute.id

  tags = {
    Name = "${var.aws_name_prefix}-cluster-security-group"
  }
}

resource "aws_security_group" "worker" {
  description = "Security group for EKS worker nodes"
  name        = "${var.aws_name_prefix}-node-security-group"
  vpc_id      = aws_vpc.rsc_exocompute.id

  tags = {
    Name = "${var.aws_name_prefix}-node-security-group"
  }
}

# Ingress/egress rules for the EKS cluster security group.

resource "aws_vpc_security_group_ingress_rule" "cluster_worker_443" {
  description = "Inbound traffic from worker nodes on port 443"

  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.worker.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "cluster_worker_1025_65535" {
  description = "Outbound traffic to worker nodes on ports 1025-65535"

  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.worker.id

  ip_protocol = "tcp"
  from_port   = 1025
  to_port     = 65535
}

# Ingress rules for the EKS worker security group.

resource "aws_vpc_security_group_ingress_rule" "worker_worker_all" {
  description = "Inbound traffic from worker nodes on all ports"

  security_group_id            = aws_security_group.worker.id
  referenced_security_group_id = aws_security_group.worker.id

  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "worker_cluster_443" {
  description = "Inbound traffic from cluster control plane on port 443"

  security_group_id            = aws_security_group.worker.id
  referenced_security_group_id = aws_security_group.cluster.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "worker_cluster_1025_65535" {
  description = "Inbound traffic from cluster control plane on ports 1025-65535"

  security_group_id            = aws_security_group.worker.id
  referenced_security_group_id = aws_security_group.cluster.id

  ip_protocol = "tcp"
  from_port   = 1025
  to_port     = 65535
}

resource "aws_vpc_security_group_egress_rule" "worker_all_ipv4" {
  description = "Outbound traffic from worker to all IPv4 addresses"

  security_group_id            = aws_security_group.worker.id
  referenced_security_group_id = aws_security_group.cluster.id

  ip_protocol = "-1"
}
