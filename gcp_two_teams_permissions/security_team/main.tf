# Example showing how to onboard a GCP service account with a specific feature
# and Terraform permissions management.
#
# The RSC service account is read from the
# RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS environment variable.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.8.0"
    }
  }
}

variable "gcp_credentials" {
  type        = string
  description = "Path to the GCP service account key file."
}

variable "project" {
  type        = string
  description = "GCP project id."
}

variable "service_account_email" {
  type        = string
  description = "GCP service account client email."
}

provider "google" {
  project = var.project
  region  = "us-west1"
  zone    = "us-west1-a"
}

provider "polaris" {}

data "polaris_gcp_permissions" "default" {
  features = [
    "CLOUD_NATIVE_PROTECTION",
  ]
}

resource "google_project_iam_custom_role" "default" {
  role_id     = "terraform"
  title       = "Terraform Test Role"
  permissions = data.polaris_gcp_permissions.default.permissions
}

resource "google_project_iam_member" "default" {
  project = var.project
  role    = google_project_iam_custom_role.default.id
  member  = "serviceAccount:${var.service_account_email}"
}

resource "polaris_gcp_service_account" "default" {
  credentials      = var.gcp_credentials
  permissions_hash = data.polaris_gcp_permissions.default.hash

  # This resource must explicitly depend on the role definition and the role
  # assignment so that the role is updated before RSC is notified.
  depends_on = [
    google_project_iam_custom_role.default,
    google_project_iam_member.default,
  ]
}
