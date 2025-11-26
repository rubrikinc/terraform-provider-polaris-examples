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

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

provider "google" {
  project = var.project_id
}

# Create a GCP service account.
module "service_account" {
  source = "../../modules/service_account"
}

# Onboard the GCP project to RSC.
module "gcp_project" {
  source = "../.."

  project_id          = var.project_id
  service_account_id  = module.service_account.service_account_id
  service_account_key = module.service_account.service_account_key

  features = {
    CLOUD_NATIVE_ARCHIVAL = {
      permission_groups = [
        "BASIC",
        "ENCRYPTION",
      ]
    },
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC",
        "EXPORT_AND_RESTORE",
        "FILE_LEVEL_RECOVERY",
      ]
    },
    GCP_SHARED_VPC_HOST = {
      permission_groups = [
        "BASIC",
      ]
    },
    EXOCOMPUTE = {
      permission_groups = [
        "BASIC",
      ]
    },
  }
}
