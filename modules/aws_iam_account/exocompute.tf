resource "polaris_aws_exocompute" "exocompute" {
  count           = var.exocompute_host_id == null ? 0 : 1
  account_id      = polaris_aws_cnp_account.account.id
  host_account_id = var.exocompute_host_id

  depends_on = [
    time_sleep.wait_for_rsc,
  ]
}
