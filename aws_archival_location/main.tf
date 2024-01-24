terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.8.0-beta.11"
    }
  }
}

variable "cloud_account_id" {
  type        = string
  description = "RSC cloud account ID."
}

variable "profile" {
  type        = string
  description = "AWS profile."
}

# The RSC service account is read from the environment variable
# RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS.
provider "polaris" {}

resource "polaris_aws_archival_location" "default" {
  account_id    = var.cloud_account_id
  name          = "my-archival-location"
  bucket_prefix = "bucket-f48wad7flz"
  storage_class = "STANDARD"
}
