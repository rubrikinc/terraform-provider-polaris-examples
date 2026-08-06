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

# Create and onboard a new Azure application/tenant with the default name and
# create an Entra ID group for the RSC Exocompute feature, adding the service
# principal as a member. Note, a tenant doesn't show up in the RSC UI until at
# least 1 subscription is added.
module "azure_tenant" {
  source = "../.."

  create_exocompute_group = true
}

output "exocompute_group_id" {
  description = "Object ID of the Entra ID Exocompute group."
  value       = module.azure_tenant.exocompute_group_id
}
