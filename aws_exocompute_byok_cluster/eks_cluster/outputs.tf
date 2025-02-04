output "aws_eks_cluster_ca_certificate" {
  value = base64decode(aws_eks_cluster.exocompute.certificate_authority.0.data)
}

output "aws_eks_cluster_endpoint" {
  value = aws_eks_cluster.exocompute.endpoint
}

output "aws_eks_cluster_name" {
  value = aws_eks_cluster.exocompute.name
}

output "aws_eks_cluster_token" {
  value = data.aws_eks_cluster_auth.exocompute.token
}
