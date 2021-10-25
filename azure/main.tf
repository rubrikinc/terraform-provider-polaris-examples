# Point Terraform to the Polaris provider.
terraform {
  required_providers {
    polaris = {
      source  = "terraform.rubrik.com/rubrikinc/polaris"
      version = "~>0.3.0"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Account name or path to Polaris service account file."
}

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

# Point the provider to the Polaris service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the Azure service principal to Polaris. See the main README for an
# explanation of this file.
resource "polaris_azure_service_principal" "default" {
  credentials = var.azure_credentials
}

# Add the Azure subscription to Polaris. This resource depends on the service
# principal resource.
resource "polaris_azure_subscription" "default" {
  subscription_id   = var.subscription_id
  subscription_name = var.subscription_name
  tenant_domain     = var.tenant_domain

  regions = [
    "eastus2"
  ]

  depends_on = [
    polaris_azure_service_principal.default
  ]
}
