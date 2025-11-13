terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=7.0.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.13.1"
    }
  }
}

variable "project_id" {
  description = "GCP project id."
  type        = string
}

provider "google" {
  project = var.project_id
}

# Create a GCP service account. The key is configured to be rotated every 30
# days. Note, key rotation requires Terraform to be run regularly. Rotation only
# occurs when Terraform is executed, meaning there will be drift between the
# rotation timestamp and actual rotation.
resource "time_rotating" "key_rotation" {
  rotation_days = 30
}

module "service_account" {
  source = "../../modules/service_account"

  rotation_trigger = time_rotating.key_rotation.rotation_rfc3339
}

# Onboard the GCP project to RSC using the service account and key.
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
    EXOCOMPUTE = {
      permission_groups = [
        "BASIC",
      ]
    },
    GCP_SHARED_VPC_HOST = {
      permission_groups = [
        "BASIC",
      ]
    },
  }
}
