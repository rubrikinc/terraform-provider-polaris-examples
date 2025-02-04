resource "aws_vpc" "exocompute" {
  cidr_block           = var.aws_exocompute_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-vpc"
  }
}

resource "aws_subnet" "exocompute_public" {
  vpc_id                  = aws_vpc.exocompute.id
  availability_zone       = "${var.aws_eks_cluster_region}a"
  cidr_block              = var.aws_exocompute_public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-public-subnet"
  }
}

resource "aws_subnet" "exocompute_subnet_1" {
  vpc_id                  = aws_vpc.exocompute.id
  availability_zone       = "${var.aws_eks_cluster_region}a"
  cidr_block              = var.aws_exocompute_subnet_1_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-subnet-1"
  }
}

resource "aws_subnet" "exocompute_subnet_2" {
  vpc_id                  = aws_vpc.exocompute.id
  availability_zone       = "${var.aws_eks_cluster_region}b"
  cidr_block              = var.aws_exocompute_subnet_2_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-subnet-2"
  }
}

resource "aws_eip" "exocompute" {
  domain = "vpc"

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-nat-eip"
  }
}

resource "aws_internet_gateway" "exocompute" {
  vpc_id = aws_vpc.exocompute.id

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-igw"
  }
}

resource "aws_nat_gateway" "exocompute" {
  allocation_id = aws_eip.exocompute.id
  subnet_id     = aws_subnet.exocompute_public.id

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-ngw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.exocompute]
}

resource "aws_route_table" "exocompute_private" {
  vpc_id = aws_vpc.exocompute.id

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-private-route-table"
  }
}

resource "aws_route_table" "exocompute_public" {
  vpc_id = aws_vpc.exocompute.id

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-public-route-table"
  }
}

resource "aws_route" "exocompute_public_ig" {
  route_table_id         = aws_route_table.exocompute_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.exocompute.id
}

resource "aws_route" "exocompute_private_ng" {
  route_table_id         = aws_route_table.exocompute_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.exocompute.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.exocompute_public.id
  route_table_id = aws_route_table.exocompute_public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.exocompute_subnet_1.id
  route_table_id = aws_route_table.exocompute_private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.exocompute_subnet_2.id
  route_table_id = aws_route_table.exocompute_private.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.exocompute.id
  service_name = "com.amazonaws.${var.aws_eks_cluster_region}.s3"

  route_table_ids = [
    aws_route_table.exocompute_private.id,
    aws_route_table.exocompute_public.id,
  ]

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-vpc-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = aws_vpc.exocompute.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_eks_cluster_region}.ec2"
  vpc_endpoint_type   = "Interface"

  security_group_ids = [
    aws_security_group.jumpbox.id,
    aws_security_group.node.id,
  ]

  subnet_ids = [
    aws_subnet.exocompute_subnet_1.id,
    aws_subnet.exocompute_subnet_2.id,
  ]

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-vpc-ec2-endpoint"
  }
}

resource "aws_vpc_endpoint" "eks" {
  vpc_id              = aws_vpc.exocompute.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_eks_cluster_region}.eks"
  vpc_endpoint_type   = "Interface"

  security_group_ids = [
    aws_security_group.jumpbox.id,
    aws_security_group.node.id,
  ]

  subnet_ids = [
    aws_subnet.exocompute_subnet_1.id,
    aws_subnet.exocompute_subnet_2.id,
  ]

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-vpc-eks-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.exocompute.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_eks_cluster_region}.ecr.api"
  vpc_endpoint_type   = "Interface"

  security_group_ids = [
    aws_security_group.jumpbox.id,
    aws_security_group.node.id,
  ]

  subnet_ids = [
    aws_subnet.exocompute_subnet_1.id,
    aws_subnet.exocompute_subnet_2.id,
  ]

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-vpc-ecr-api-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.exocompute.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_eks_cluster_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"

  security_group_ids = [
    aws_security_group.jumpbox.id,
    aws_security_group.node.id,
  ]

  subnet_ids = [
    aws_subnet.exocompute_subnet_1.id,
    aws_subnet.exocompute_subnet_2.id,
  ]

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-vpc-ecr-dkr-endpoint"
  }
}

resource "aws_vpc_endpoint" "autoscaling" {
  vpc_id              = aws_vpc.exocompute.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_eks_cluster_region}.autoscaling"
  vpc_endpoint_type   = "Interface"

  security_group_ids = [
    aws_security_group.jumpbox.id,
    aws_security_group.node.id,
  ]

  subnet_ids = [
    aws_subnet.exocompute_subnet_1.id,
    aws_subnet.exocompute_subnet_2.id,
  ]

  tags = {
    Name = "${var.aws_name_prefix}-exocompute-vpc-autoscaling-endpoint"
  }
}
