# Register the subscription as a shared exocompute application account, using the
# exocompute resources deployed by the host subscription.
resource "polaris_azure_exocompute" "exocompute" {
  count                 = var.exocompute_host_id == null ? 0 : 1
  cloud_account_id      = polaris_azure_subscription.subscription.id
  host_cloud_account_id = var.exocompute_host_id

  depends_on = [
    time_sleep.wait_for_rsc,
  ]
}
