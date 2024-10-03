# Example showing how to add an AWS data center cloud account and create an
# Amazon S3 data center archival location.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.10.0-beta.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.6.0"
    }
    time = {
      source = "hashicorp/time"
      version = "~>0.12.0"
    }
  }
}

variable "account_name" {
  description = "Data center AWS account name."
  type        = string
  default     = "archival-location-account"
}

variable "access_key" {
  description = "AWS access key."
  type        = string
}

variable "secret_key" {
  description = "AWS secret key."
  type        = string
}

variable "archival_location_name" {
  description = "Data center archival location name."
  type        = string
  default     = "archival-location"
}

variable "bucket_name" {
  description = "AWS S3 bucket name."
  type        = string
  default     = "archival-location-bucket"
}

variable "region" {
  description = "AWS S3 region."
  type        = string
  default     = "us-east-2"
}

variable "cluster_id" {
  description = "Rubrik cluster ID."
  type        = string
}

variable "rsa_key" {
  description = "RSA encryption key."
  type        = string
}

provider "polaris" {}

# We add an 8 character random suffix to the AWS account name to work around
# a technical short coming in RSC where data center account names cannot be
# reused.
resource "random_string" "account_suffix" {
  length  = 8
  numeric = false
  special = false
  upper   = false
}

resource "polaris_data_center_aws_account" "account" {
  name        = "${var.account_name}-${random_string.account_suffix.result}"
  access_key  = var.access_key
  secret_key  = var.secret_key
}

# We add an 8 character random suffix to the bucket name to allow for the
# example to created and destroyed multiple times without removing the bucket
# created by RSC for each run.
resource "random_string" "bucket_suffix" {
  length  = 8
  numeric = false
  special = false
  upper   = false
}

# We add a 60 second sleep when destroying the resources to allow for the
# archival location to be destroyed before the the data center account.
resource "time_sleep" "wait_60_seconds" {
  destroy_duration = "60s"

  depends_on = [
    polaris_data_center_aws_account.account,
  ]
}

resource "polaris_data_center_archival_location_amazon_s3" "archival_location" {
  name             = var.archival_location_name
  region           = var.region
  bucket_name      = "${var.bucket_name}-${random_string.bucket_suffix.result}"
  cloud_account_id = polaris_data_center_aws_account.account.id
  cluster_id       = var.cluster_id
  rsa_key          = var.rsa_key

  depends_on = [
    time_sleep.wait_60_seconds,
  ]
}
