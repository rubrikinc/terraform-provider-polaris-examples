locals {
  # The key ring data source searches on name prefix. So multiple key rings with
  # the same prefix might be returned. Filter on exact name.
  key_ring = one([
    for v in data.google_kms_key_rings.key_rings.key_rings : v if v.name == var.key_ring_name
  ])

  # The key data source searches on name prefix. So multiple keys with the same
  # prefix might be returned. Filter on exact name.
  key = one([
    for v in try(data.google_kms_crypto_keys.keys[0].keys, []) : v if v.name == var.key_name
  ])
}

data "google_kms_key_rings" "key_rings" {
  location = var.region
  filter   = "name:${var.key_ring_name}"
}

data "google_kms_crypto_keys" "keys" {
  count    = local.key_ring != null ? 1 : 0
  key_ring = local.key_ring.id
  filter   = "name:${var.key_name}"
}

resource "google_kms_key_ring" "key_ring" {
  count    = local.key_ring == null ? 1 : 0
  location = var.region
  name     = var.key_ring_name
}

resource "google_kms_crypto_key" "key" {
  count           = local.key == null ? 1 : 0
  key_ring        = local.key_ring != null ? local.key_ring.id : google_kms_key_ring.key_ring[0].id
  labels          = var.labels
  name            = var.key_name
  rotation_period = var.key_rotation_period
}
