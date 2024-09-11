output "aws_eks_cluster_ca_certificate" {
  value = base64decode(aws_eks_cluster.exocompute.certificate_authority.0.data)
}

output "aws_eks_cluster_endpoint" {
  value = aws_eks_cluster.exocompute.endpoint
}

output "aws_eks_cluster_name" {
  value = aws_eks_cluster.exocompute.name
}

output "aws_vpc_id" {
  value = aws_vpc.exocompute.id
}

output "aws_public_subnet_id" {
  value = aws_subnet.exocompute_public.id
}

output "jumpbox_security_group_id" {
  value = aws_security_group.jumpbox.id
}
