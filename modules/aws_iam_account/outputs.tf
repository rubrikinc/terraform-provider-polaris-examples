output "cloud_account_id" {
  description = "RSC cloud account ID for the AWS account."
  value       = polaris_aws_cnp_account.account.id

  depends_on = [
    time_sleep.wait_for_rsc
  ]
}
