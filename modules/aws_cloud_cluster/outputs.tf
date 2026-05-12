# Outputs for the Rubrik Polaris Cloud Cluster Module

output "cloud_cluster_id" {
  description = "The ID of the Rubrik Polaris cloud cluster"
  value       = polaris_aws_cloud_cluster.example.id
}

output "cloud_cluster_name" {
  description = "The name of the Rubrik Polaris cloud cluster"
  value       = polaris_aws_cloud_cluster.example.cluster_config[0].cluster_name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.vpc_id
}

output "subnet_id" {
  description = "The ID of the subnet used for the cluster"
  value       = var.subnet_id
}

output "security_group_ids" {
  description = "The IDs of the security groups"
  value       = local.security_group_ids
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = local.bucket_name
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = var.bucket_name == null ? module.s3[0].bucket_arn : null
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = var.security_group_ids == null ? module.security_group[0].security_group_id : null
}

output "security_group_arn" {
  description = "The ARN of the security group"
  value       = var.security_group_ids == null ? module.security_group[0].security_group_arn : null
}

output "iam_role_arn" {
  description = "The ARN of the IAM role"
  value       = var.instance_profile_name == null ? module.iam[0].iam_role_arn : null
}

output "iam_instance_profile_name" {
  description = "The name of the IAM instance profile"
  value       = local.instance_profile_name
}

output "iam_instance_profile_arn" {
  description = "The ARN of the IAM instance profile"
  value       = var.instance_profile_name == null ? module.iam[0].iam_instance_profile_arn : null
}

output "s3_policy_arn" {
  description = "The ARN of the S3 access policy"
  value       = var.instance_profile_name == null ? module.iam[0].s3_policy_arn : null
}
