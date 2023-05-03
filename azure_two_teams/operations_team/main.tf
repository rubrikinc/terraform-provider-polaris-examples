# Point Terraform to the RSC provider.
terraform {
  required_providers {
    polaris = {
      source = "rubrikinc/polaris"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Path to the RSC service account file."
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

# Add the Azure subscription to RSC. This resource depends on the service
# principal resource.
resource "polaris_azure_subscription" "default" {
  subscription_id   = var.subscription_id
  subscription_name = var.subscription_name
  tenant_domain     = var.tenant_domain

  cloud_native_protection {
    regions = [
      "eastus2"
    ]
  }
}
