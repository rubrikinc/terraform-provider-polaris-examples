# Example showing how to onboard an Azure subscription and create an Exocompute
# configuration for the subscription.
#
# The RSC service account is read from the
# RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS environment variable.
#
# The Azure credentials is expected to be passed in using a custom service
# principal file. For an explanation of the custom file format, see:
# https://github.com/rubrikinc/rubrik-polaris-sdk-for-go?tab=readme-ov-file#azure-credentials

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.8.0"
    }
  }
}

variable "azure_credentials" {
  type        = string
  description = "Path to the custom service principal file."
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID."
}

variable "subscription_name" {
  type        = string
  description = "Azure subscription name."
}

variable "tenant_domain" {
  type        = string
  description = "Azure tenant domain."
}

variable "subnet" {
  type        = string
  description = "Azure subnet."
}

provider "polaris" {}

resource "polaris_azure_service_principal" "tenant" {
  credentials   = var.azure_credentials
  tenant_domain = var.tenant_domain
}

resource "polaris_azure_subscription" "subscription" {
  subscription_id   = var.subscription_id
  subscription_name = var.subscription_name
  tenant_domain     = polaris_azure_service_principal.tenant.tenant_domain

  cloud_native_protection {
    regions = [
      "eastus2",
    ]
  }

  exocompute {
    regions = [
      "eastus2",
    ]
  }
}

resource "polaris_azure_exocompute" "exocompute" {
  subscription_id = polaris_azure_subscription.subscription.id
  region          = "eastus2"
  subnet          = var.subnet
}
