terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.48.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.99.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.9.1"
    }
  }
}

variable "application_name_prefix" {
  description = "Name prefix for the Azure AD applications. The cloud native protection and Azure DevOps applications append ` - CNP` and ` - DevOps` to it."
  type        = string
  default     = "Rubrik Security Cloud"
}

variable "native_id" {
  description = "Azure DevOps organization native ID, i.e. the organization name in the Azure DevOps URL (e.g. my-org from https://dev.azure.com/my-org)."
  type        = string
}

variable "region" {
  description = "Azure region for the Rubrik-hosted exocompute."
  type        = string
  default     = "eastus2"
}

variable "onboarding_shell" {
  description = "Shell used to run the onboarding script during the apply. One of `bash` (default) or `powershell`."
  type        = string
  default     = "bash"
}

variable "tags" {
  description = "Tags to apply to Azure resources which support tags."
  type        = map(string)
  default = {
    Example    = "rubrik_hosted"
    Module     = "azure_devops"
    Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

# Register the service principal for the Azure DevOps use case.
module "azure_tenant_devops" {
  source       = "../../../azure_tenant"
  use_case     = "AZURE_DEVOPS"
  display_name = "${var.application_name_prefix} - DevOps"
}

# Onboard the Azure DevOps organization to RSC using Rubrik-hosted exocompute
# and RCV auto-provisioned storage. The generated onboarding script is run
# against the organization as part of the apply.
module "azure_devops" {
  source = "../.."

  # Organization settings.
  native_id        = var.native_id
  tenant_domain    = module.azure_tenant_devops.tenant_domain
  onboarding_shell = var.onboarding_shell

  features = {
    AZURE_DEVOPS_REPOSITORY_PROTECTION = {
      permission_groups = [
        "BASIC",
        "RECOVERY",
      ]
    }
  }

  # Exocompute settings.
  exocompute_host_type = "RUBRIK_HOST"
  exocompute_region    = var.region

  # Storage settings.
  storage_type = "RCV"

  depends_on = [
    module.azure_tenant_devops.app_id,
  ]
}
