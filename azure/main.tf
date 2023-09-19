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
      "eastus2"
    ]
  }
}
