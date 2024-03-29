terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.7.0"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Path to the RSC service account file."
}

variable "profile" {
  type        = string
  description = "AWS profile."
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID."
}

variable "subnet1" {
  type        = string
  description = "AWS subnet 1."
}

variable "subnet2" {
  type        = string
  description = "AWS subnet 2."
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the AWS account to RSC.
resource "polaris_aws_account" "default" {
  profile = var.profile

  cloud_native_protection {
    regions = [
      "us-east-2",
    ]
  }

  exocompute {
    regions = [
      "us-east-2",
    ]
  }
}

# Create an excompute configuration using the specified VPC and subnets.
resource "polaris_aws_exocompute" "default" {
  account_id = polaris_aws_account.default.id
  region     = "us-east-2"
  vpc_id     = var.vpc_id

  subnets = [
    var.subnet1,
    var.subnet2,
  ]
}
