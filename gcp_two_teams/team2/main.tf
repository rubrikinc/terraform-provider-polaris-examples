# Example showing how to onboard a GCP project with an already onboarded GCP
# service account.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.0.0"
    }
  }
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

provider "polaris" {}

resource "polaris_gcp_project" "default" {
  organization_name = var.organization_name
  project           = var.project
  project_name      = var.project_name
  project_number    = var.project_number

  cloud_native_protection {}
}
