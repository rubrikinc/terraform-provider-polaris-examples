resource "aws_security_group" "node" {
  description = "Security group for EKS nodes"
  name        = "${var.aws_name_prefix}-node-security-group"
  vpc_id      = aws_vpc.exocompute.id

  tags = {
    Name = "${var.aws_name_prefix}-node-security-group"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4" {
  description = "Allow outbound traffic to all IPv4 address"

  security_group_id = aws_security_group.node.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_self" {
  description = "Allow inbound traffic from self"

  security_group_id            = aws_security_group.node.id
  referenced_security_group_id = aws_security_group.node.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_cluster" {
  description = "Allow inbound traffic from cluster control plane"

  security_group_id            = aws_security_group.node.id
  referenced_security_group_id = aws_eks_cluster.exocompute.vpc_config[0].cluster_security_group_id
  ip_protocol                  = "-1"
}
