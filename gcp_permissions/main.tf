# Example of how to manage Polaris GCP permissions.

# Point Terraform to the Polaris provider.
terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "~>0.3.0"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Account name or path to the Polaris service account file."
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

# Initalize the Google provider from the shell environment.
provider "google" {
  project = var.project
  region  = "us-west1"
  zone    = "us-west1-a"
}

# Points the Polaris provider to the Polaris service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# GCP permissions required for Cloud Native Protection.
data "polaris_gcp_permissions" "default" {
  features = [
    "cloud-native-protection",
  ]
}

# Create a role in GCP called terraform which has the required permissions.
resource "google_project_iam_custom_role" "default" {
  role_id     = "terraform"
  title       = "Terraform Test Role"
  permissions = data.polaris_gcp_permissions.default.permissions
}

# Assign the role to the service account used by Polaris.
resource "google_project_iam_member" "default" {
  role   = google_project_iam_custom_role.default.id
  member = "serviceAccount:${var.service_account_email}"
}

# Add the GCP project to Polaris.
resource "polaris_gcp_project" "default" {
  credentials      = var.gcp_credentials
  permissions_hash = data.polaris_gcp_permissions.default.hash
  project          = var.project

  cloud_native_protection {
  }

  depends_on = [
    google_project_iam_custom_role.default,
    google_project_iam_member.default,
  ]
}
