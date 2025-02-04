# Example showing how to create an exocompute configuration for a subscription
# already onboarded.
#
# Use the azure example to onboard a subscription with the EXOCOMPUTE feature.

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
  description = "RSC cloud account ID of the subscription."
}

variable "pod_overlay_network_cidr" {
  type        = string
  description = "CIDR block for the exocompute pod overlay network."
}

variable "region" {
  type        = string
  description = "Azure exocompute region."
  default     = "eastus2"
}

variable "subnet_id" {
  type        = string
  description = "Azure subnet ID."
}

provider "polaris" {}

resource "polaris_azure_exocompute" "exocompute" {
  cloud_account_id         = var.cloud_account_id
  pod_overlay_network_cidr = var.pod_overlay_network_cidr
  region                   = var.region
  subnet                   = var.subnet_id
}
