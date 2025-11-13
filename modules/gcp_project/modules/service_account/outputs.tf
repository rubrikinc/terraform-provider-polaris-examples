output "service_account_id" {
  description = "The fully qualified GCP service account ID."
  value       = google_service_account.service_account.id
}

output "service_account_key" {
  description = "The base64-encoded private key for the GCP service account."
  sensitive   = true
  value       = google_service_account_key.service_account.private_key
}
