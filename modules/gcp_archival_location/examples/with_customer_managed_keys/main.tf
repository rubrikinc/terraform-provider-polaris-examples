terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=7.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.0"
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

# Onboard the GCP project to RSC. Note, the CLOUD_NATIVE_ARCHIVAL feature have
# both the BASIC and the ENCRYPTION permission groups.
module "gcp_project" {
  source = "../../../gcp_project"

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
  }
}

# Create a KMS key ring and crypto key.
module "crypto_key" {
  source = "../../../gcp_archival_location/modules/crypto_key"

  key_name      = "my-key"
  key_ring_name = "my-key-ring"
  region        = "us-central1"

  labels = var.labels
}

# Create an RSC archival location with customer managed keys.
# This example enables customer managed keys for a specific region. If the
# region field is not specified, a customer managed key block for each source
# region must be specified. Source regions not having a customer managed key
# block will have its data encrypted with platform managed keys.
module "gcp_archival_location" {
  source = "../../../gcp_archival_location"

  bucket_labels    = var.labels
  bucket_prefix    = "my-bucket-prefix"
  cloud_account_id = module.gcp_project.cloud_account_id
  name             = "my-archival-location"
  region           = "us-central1"
  storage_class    = "STANDARD"

  customer_managed_keys = [{
    name      = "my-key"
    ring_name = "my-key-ring"
    region    = "us-central1"
  }]

  depends_on = [
    module.crypto_key,
  ]
}

# A basic for of lifecycle protection to prevent accidental deletion of the
# crypto key. To remove the protection, set prevent_destroy to false.
resource "null_resource" "prevent_destroy" {
  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    module.crypto_key,
  ]
}
