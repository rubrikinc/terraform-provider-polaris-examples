# Example showing how to onboard an Azure subscription and create an Exocompute
# configuration for the subscription. Note that the same resource group is used
# for both RSC features, this is not a requirement.
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
      version = "=0.9.0-beta.2"
    }
  }
}

variable "azure_credentials" {
  type        = string
  description = "Path to the custom service principal file."
}

variable "pod_overlay_network_cidr" {
  type        = string
  description = "CIDR address for the pod overlay network."
}

variable "resource_group_name" {
  type        = string
  description = "Azure resource group name."
}

variable "resource_group_region" {
  type        = string
  description = "Azure resource group region."
}

variable "subnet" {
  type        = string
  description = "Azure subnet."
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

provider "polaris" {}

resource "polaris_azure_service_principal" "tenant" {
  credentials   = var.azure_credentials
  tenant_domain = var.tenant_domain
}

resource "polaris_azure_subscription" "subscription" {
  subscription_id   = var.subscription_id
  subscription_name = var.subscription_name
  tenant_domain     = polaris_azure_service_principal.tenant.tenant_domain

  exocompute {
    resource_group_name   = var.resource_group_name
    resource_group_region = var.resource_group_region

    regions = [
      "eastus2",
    ]
  }
}

resource "polaris_azure_exocompute" "exocompute" {
  cloud_account_id         = polaris_azure_subscription.subscription.id
  pod_overlay_network_cidr = var.pod_overlay_network_cidr
  region                   = "eastus2"
  subnet                   = var.subnet
}
