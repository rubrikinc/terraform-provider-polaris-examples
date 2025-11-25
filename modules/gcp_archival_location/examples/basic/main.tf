terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=7.0.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.3.0"
    }
  }
}

variable "labels" {
  description = "Labels to apply to GCP resources created which supports labels."
  type        = map(string)
  default = {
    example    = "basic"
    module     = "gcp_archival_location"
    repository = "terraform-provider-polaris-examples"
  }
}

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

provider "google" {
  project = var.project_id
}

# Create a GCP service account.
module "service_account" {
  source = "../../../gcp_project/modules/service_account"
}

# Onboard the GCP project to RSC.
module "gcp_project" {
  source = "../../../gcp_project"

  project_id          = var.project_id
  service_account_id  = module.service_account.service_account_id
  service_account_key = module.service_account.service_account_key

  features = {
    CLOUD_NATIVE_ARCHIVAL = {
      permission_groups = [
        "BASIC",
      ]
    },
  }
}

# Create an RSC archival location.
module "gcp_archival_location" {
  source = "../.."

  bucket_labels    = var.labels
  bucket_prefix    = "my-bucket-prefix"
  cloud_account_id = module.gcp_project.cloud_account_id
  name             = "my-archival-location"
  region           = "us-central1"
  storage_class    = "STANDARD"
}
