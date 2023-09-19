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

# See the README in https://github.com/rubrikinc/rubrik-polaris-sdk-for-go for
# an explanation of the service principal file.
variable "azure_credentials" {
  type        = string
  description = "Path to the Azure service principal file."
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription id."
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

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the Azure service principal to RSC.
resource "polaris_azure_service_principal" "default" {
  credentials   = var.azure_credentials
  tenant_domain = var.tenant_domain
}

# Add the Azure subscription to RSC.
resource "polaris_azure_subscription" "default" {
  subscription_id   = var.subscription_id
  subscription_name = var.subscription_name
  tenant_domain     = polaris_azure_service_principal.default.tenant_domain

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

# Create an excompute configuration using the specified subnet.
resource "polaris_azure_exocompute" "default" {
  subscription_id = polaris_azure_subscription.default.id
  region          = "eastus2"
  subnet          = var.subnet
}
