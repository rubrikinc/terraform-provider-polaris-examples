# Example showing how to onboard an Azure subscription with an already onboarded
# Azure service principal.
#
# The credentials for Azure are read from the shell environment. The RSC service
# account is read from the RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS environment
# variable.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.99.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.8.0"
    }
  }
}

variable "tenant_domain" {
  type        = string
  description = "Azure tenant primary domain."
}

provider "azurerm" {
  features {}
}

provider "polaris" {}

data "azurerm_subscription" "subscription" {}

resource "polaris_azure_subscription" "subscription" {
  subscription_id   = data.azurerm_subscription.subscription.subscription_id
  subscription_name = data.azurerm_subscription.subscription.display_name
  tenant_domain     = var.tenant_domain

  cloud_native_protection {
    regions = [
      "eastus2"
    ]
  }
}
