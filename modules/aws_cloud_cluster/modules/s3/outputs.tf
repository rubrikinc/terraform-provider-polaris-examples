# Outputs for S3 Module

output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.rubrik_storage.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.rubrik_storage.arn
}

output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.rubrik_storage.bucket
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.rubrik_storage.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket regional domain name"
  value       = aws_s3_bucket.rubrik_storage.bucket_regional_domain_name
}
