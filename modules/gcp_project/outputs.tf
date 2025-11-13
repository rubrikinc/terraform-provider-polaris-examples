output "cloud_account_id" {
  description = "RSC cloud account ID for the GCP project."
  value       = polaris_gcp_project.project.id

  depends_on = [
    time_sleep.wait_for_rsc
  ]
}
