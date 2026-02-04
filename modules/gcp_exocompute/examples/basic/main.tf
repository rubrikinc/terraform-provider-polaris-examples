terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=7.0.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.4.0"
    }
  }
}

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "regional_configs" {
  description = "Regional exocompute configuration."
  type = set(object({
    region      = string
    subnet_name = string
    vpc_name    = string
  }))
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
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC",
        "EXPORT_AND_RESTORE",
        "FILE_LEVEL_RECOVERY",
      ]
    },
    EXOCOMPUTE = {
      permission_groups = [
        "BASIC",
      ]
    },
  }
}

# Create an RSC exocompute configuration for the cloud account.
module "gcp_exocompute" {
  source = "../.."

  cloud_account_id     = module.gcp_project.cloud_account_id
  regional_configs     = var.regional_configs
  trigger_health_check = false
}
