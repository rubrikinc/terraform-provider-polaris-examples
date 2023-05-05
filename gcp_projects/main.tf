# Point Terraform to the RSC provider.
terraform {
  required_providers {
    polaris = {
      source = "rubrikinc/polaris"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Path to the RSC service account file."
}

# The projects.csv file should contain all GCP projects to add to RSC, using the
# following format:
#
# project,credentials
# "<project-1>","<service-account-1>"
# "<project-2>","<service-account-2>"
# "<project-N>","<service-account-N>"
#
# E.g:
#
# project,credentials
# "my-proj","my-proj-service-account.json"
# "another-proj","another-proj-service-account.json"
#
# The header, the first line of the CSV file, must also be included in the CSV
# file.
#
# After the projects have been added they can be managed through the CSV file.
# Removing a project from the CSV file followed by running terraform apply will
# remove the project from RSC.
locals {
  projects = csvdecode(file("projects.csv"))
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the GCP projects from the projects.csv file to RSC.
resource "polaris_gcp_project" "projects" {
  for_each = {
    for project in local.projects : project.project => project
  }

  credentials = each.value.credentials
  project     = each.key

  cloud_native_protection {
  }
}
