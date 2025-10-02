output "cloud_account_id" {
  description = "RSC cloud account ID for the AWS account."
  value       = polaris_aws_cnp_account.account.id
}
