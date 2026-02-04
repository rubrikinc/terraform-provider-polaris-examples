# Outputs for IAM Module

output "iam_role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.rubrik_cluster.arn
}

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = aws_iam_role.rubrik_cluster.name
}

output "iam_instance_profile_name" {
  description = "The name of the IAM instance profile"
  value       = aws_iam_instance_profile.rubrik_cluster.name
}

output "iam_instance_profile_arn" {
  description = "The ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.rubrik_cluster.arn
}

output "s3_policy_arn" {
  description = "The ARN of the S3 access policy"
  value       = aws_iam_policy.rubrik_s3_access.arn
}
