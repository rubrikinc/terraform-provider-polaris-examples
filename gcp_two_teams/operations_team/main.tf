terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.7.0"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Path to the RSC service account file."
}

variable "organization_name" {
  type        = string
  description = "GCP organization name."
}

variable "project" {
  type        = string
  description = "GCP project id."
}

variable "project_name" {
  type        = string
  description = "GCP project name."
}

variable "project_number" {
  type        = number
  description = "GCP project number."
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the GCP project to RSC. RSC will authenticate to GCP using the previously
# added GCP service account.
resource "polaris_gcp_project" "default" {
  organization_name = var.organization_name
  project           = var.project
  project_name      = var.project_name
  project_number    = var.project_number

  cloud_native_protection {
  }
}
