terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.48.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.9.1"
    }
  }
}

provider "azuread" {}

# Create and onboard a new Azure application/tenant with the default name. Note,
# a tenant doesn't show up in the RSC UI until at least 1 subscription is added.
module "azure_tenant" {
  source = "../.."
}
