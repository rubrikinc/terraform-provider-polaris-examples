output "aws_eks_cluster_ca_certificate" {
  value = base64decode(aws_eks_cluster.rsc_exocompute.certificate_authority.0.data)
}

output "aws_eks_cluster_endpoint" {
  value = aws_eks_cluster.rsc_exocompute.endpoint
}

output "aws_eks_cluster_name" {
  value = aws_eks_cluster.rsc_exocompute.name
}

output "aws_eks_cluster_token" {
  value = data.aws_eks_cluster_auth.rsc_exocompute.token
}
