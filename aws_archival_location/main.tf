# Example showing how to create an AWS archival location for an existing AWS
# cloud account in RSC.
#
# See the aws_cnp_account example for how to onboard an AWS account with the
# CLOUD_NATIVE_ARCHIVAL feature. The RSC service account is read from the
# RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS environment variable.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.8.0"
    }
  }
}

variable "cloud_account_id" {
  type        = string
  description = "RSC cloud account ID."
}

provider "polaris" {}

resource "polaris_aws_archival_location" "archival_location" {
  account_id    = var.cloud_account_id
  name          = "my-archival-location"
  bucket_prefix = "bucket-f48wad7flz"
  storage_class = "STANDARD"
}
