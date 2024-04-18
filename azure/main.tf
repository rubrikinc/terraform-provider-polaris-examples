# Example showing how to onboard an Azure service principal, also referred to
# as app registration or tenant, and an Azure subscription to RSC.
#
# The RSC service account is read from the
# RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS environment variable.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.8.0"
    }
  }
}

variable "app_id" {
  type        = string
  description = "Azure app registration application ID. Also known as the client ID."
}

variable "app_name" {
  type        = string
  description = "Azure app registration display name."
}

variable "app_secret" {
  type        = string
  sensitive   = true
  description = "Azure app registration client secret."
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID."
}

variable "subscription_name" {
  type        = string
  description = "Azure subscription name."
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID. Also known as the directory ID."
}

variable "tenant_domain" {
  type        = string
  description = "Azure tenant primary domain."
}

provider "polaris" {}

resource "polaris_azure_service_principal" "tenant" {
  app_id        = var.app_id
  app_name      = var.app_name
  app_secret    = var.app_secret
  tenant_id     = var.tenant_id
  tenant_domain = var.tenant_domain
}

resource "polaris_azure_subscription" "subscription" {
  subscription_id   = var.subscription_id
  subscription_name = var.subscription_name
  tenant_domain     = polaris_azure_service_principal.tenant.tenant_domain

  cloud_native_protection {
    regions = [
      "eastus2"
    ]
  }
}
