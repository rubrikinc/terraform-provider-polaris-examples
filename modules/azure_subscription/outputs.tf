output "cloud_account_id" {
  description = "RSC cloud account ID of the onboarded Azure subscription."
  value       = polaris_azure_subscription.subscription.id

  depends_on = [
    time_sleep.wait_for_rsc
  ]
}
