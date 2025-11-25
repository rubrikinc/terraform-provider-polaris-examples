data "polaris_gcp_project" "project" {
  id = var.cloud_account_id

  lifecycle {
    postcondition {
      condition     = contains([for v in self.feature : v.name], "CLOUD_NATIVE_ARCHIVAL")
      error_message = "Archival locations require the CLOUD_NATIVE_ARCHIVAL RSC feature."
    }
    postcondition {
      condition     = var.customer_managed_keys == null || contains(flatten([for v in self.feature : v.permission_groups]), "ENCRYPTION")
      error_message = "Customer managed keys require the ENCRYPTION permission group for the CLOUD_NATIVE_ARCHIVAL RSC feature."
    }
  }
}

data "google_project" "project" {
  project_id = data.polaris_gcp_project.project.project_id
}

data "google_kms_key_ring" "key_ring" {
  for_each = var.customer_managed_keys == null ? {} : {
    for v in var.customer_managed_keys : "${v.region}/${v.ring_name}" => v
  }

  name     = each.value.ring_name
  location = each.value.region
}

data "google_kms_crypto_key" "key" {
  for_each = var.customer_managed_keys == null ? {} : {
    for v in var.customer_managed_keys : "${v.region}/${v.ring_name}/${v.name}" => v
  }

  name     = each.value.name
  key_ring = data.google_kms_key_ring.key_ring["${each.value.region}/${each.value.ring_name}"].id
}

resource "google_kms_crypto_key_iam_member" "key" {
  for_each = var.customer_managed_keys == null ? {} : {
    for v in var.customer_managed_keys : "${v.region}/${v.ring_name}/${v.name}" => v
  }

  crypto_key_id = data.google_kms_crypto_key.key[each.key].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

resource "polaris_gcp_archival_location" "archival_location" {
  bucket_labels    = var.bucket_labels
  bucket_prefix    = var.bucket_prefix
  cloud_account_id = var.cloud_account_id
  name             = var.name
  region           = var.region
  storage_class    = var.storage_class

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_keys != null ? var.customer_managed_keys : []
    content {
      name      = customer_managed_key.value.name
      region    = customer_managed_key.value.region
      ring_name = customer_managed_key.value.ring_name
    }
  }

  depends_on = [
    data.polaris_gcp_project.project,
    data.google_kms_key_ring.key_ring,
    data.google_kms_crypto_key.key,
    google_kms_crypto_key_iam_member.key,
  ]
}
