output "cloud_account_id" {
  description = "RSC cloud account ID for the AWS account."
  value       = polaris_azure_subscription.subscription.id

  depends_on = [
    polaris_azure_subscription.subscription,
  ]
}
