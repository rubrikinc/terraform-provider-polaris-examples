# Example showing how to create an AWS cloud native archival location for an
# account already onboarded.
#
# Use the aws_cnp_account example to onboard an account with the
# CLOUD_NATIVE_ARCHIVAL feature.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.10.0-beta.4"
    }
  }
}

variable "cloud_account_id" {
  type        = string
  description = "RSC cloud account ID of the account."
}

variable "archival_location_name" {
  type        = string
  description = "Archival location name."
  default     = "My Archival Location"
}

variable "bucket_prefix" {
  type        = string
  description = "AWS S3 bucket prefix."
  default     = "bucket-f48wad7flz"
}

provider "polaris" {}

resource "polaris_aws_archival_location" "archival_location" {
  account_id    = var.cloud_account_id
  name          = var.archival_location_name
  bucket_prefix = var.bucket_prefix
}
