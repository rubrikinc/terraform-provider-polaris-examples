resource "google_service_account" "service_account" {
  account_id   = var.account_id
  display_name = var.display_name != null ? var.display_name : title(replace(var.account_id, "/[-_]/", " "))
}

resource "google_service_account_key" "service_account" {
  service_account_id = google_service_account.service_account.name

  keepers = {
    rotation_trigger = var.rotation_trigger
  }
}
