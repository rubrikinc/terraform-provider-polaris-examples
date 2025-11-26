output "key_id" {
  description = "The GCP crypto key ID."
  value       = local.key != null ? local.key.id : google_kms_crypto_key.key[0].id
}

output "key_rotation_period" {
  description = "The GCP crypto key rotation period."
  value       = local.key != null ? local.key.rotation_period : google_kms_crypto_key.key[0].rotation_period
}

# The key_name and key_ring_name outputs should have the same values as the
# passed in variables. They are outputted to simply testing.

output "key_name" {
  description = "The GCP crypto key name."
  value       = local.key != null ? local.key.name : google_kms_crypto_key.key[0].name
}

output "key_ring_name" {
  description = "The GCP key ring name."
  value       = local.key_ring != null ? local.key_ring.name : google_kms_key_ring.key_ring[0].name
}
