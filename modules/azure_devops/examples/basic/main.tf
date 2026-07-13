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
      source  = rubrikinc/polaris
      version = ">=1.9.0"
    }
  }
}

variable "archival_name" {
  description = "Name of the RSC archival location."
  type        = string
  default     = "archival-location"
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
  description = "Azure region for the subscription, resource group, exocompute cluster and archival location."
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Resource group name for the cloud native archival and exocompute features."
  type        = string
  default     = "rubrik-azure-devops-example"
}

variable "run_onboarding_script" {
  description = "Onboarding script variant to run during the apply. One of `bash` (default) or `powershell`. Set to `powershell` on Windows."
  type        = string
  default     = "bash"
}

variable "storage_account_name_prefix" {
  description = "Azure storage account name prefix. Can only consist of lower case letters and numbers."
  type        = string
  default     = "rubrikarchival"
}

variable "subnet_id" {
  description = "Azure subnet ID for the exocompute cluster."
  type        = string
}

variable "tags" {
  description = "Tags to apply to Azure resources which support tags."
  type        = map(string)
  default = {
    Example    = "basic"
    Module     = "azure_devops"
    Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

locals {
  # Cloud native features onboarded on the Azure subscription that hosts the
  # exocompute cluster and the archival location.
  features = {
    CLOUD_NATIVE_ARCHIVAL = {
      permission_groups = [
        "BASIC",
      ]
    }
    EXOCOMPUTE = {
      permission_groups = [
        "BASIC",
      ]
    }
  }
}

# Register the service principal used to onboard the Azure subscription hosting
# exocompute and archival. Credentials are stored separately per use case, so
# this cloud native protection principal is distinct from the Azure DevOps one
# registered below, even though both live in the same tenant.
module "azure_tenant_cnp" {
  source       = "../../../azure_tenant"
  use_case     = "CLOUD_NATIVE_PROTECTION"
  display_name = "${var.application_name_prefix} - CNP"
}

# Register the service principal for the Azure DevOps use case.
module "azure_tenant_devops" {
  source       = "../../../azure_tenant"
  use_case     = "AZURE_DEVOPS"
  display_name = "${var.application_name_prefix} - DevOps"
}

# Create the resource group required by the cloud native features.
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.region
  tags     = var.tags
}

# Onboard the Azure subscription with the exocompute and cloud native archival
# features.
module "azure_subscription" {
  source = "../../../azure_subscription"

  features      = local.features
  principal_id  = module.azure_tenant_cnp.object_id
  tenant_domain = module.azure_tenant_cnp.tenant_domain

  default_resource_group = {
    name = var.resource_group_name
    tags = var.tags
  }

  regions = [
    var.region,
  ]

  depends_on = [
    azurerm_resource_group.resource_group,
  ]
}

# Configure exocompute in the onboarded subscription. The Azure DevOps
# organization runs its backups on this cluster.
module "azure_exocompute" {
  source = "../../../azure_exocompute"

  cloud_account_id         = module.azure_subscription.cloud_account_id
  pod_overlay_network_cidr = "10.244.0.0/16"
  region                   = var.region
  subnet_id                = var.subnet_id
}

# Create the archival location that stores the Azure DevOps backups.
module "azure_archival_location" {
  source = "../../../azure_archival_location"

  cloud_account_id            = module.azure_subscription.cloud_account_id
  name                        = var.archival_name
  storage_account_name_prefix = var.storage_account_name_prefix
  storage_account_region      = var.region
  storage_account_tags        = var.tags
}

# Onboard the Azure DevOps organization to RSC using the customer-hosted
# exocompute and archival location provisioned above. The generated onboarding
# script is run against the organization as part of the apply.
module "azure_devops" {
  source = "../.."

  native_id             = var.native_id
  tenant_domain         = module.azure_tenant_devops.tenant_domain
  run_onboarding_script = var.run_onboarding_script

  exocompute_host_type = "CUSTOMER_HOST"
  exocompute_host_id   = module.azure_subscription.cloud_account_id

  archival_location_id = module.azure_archival_location.archival_location_id
  storage_type         = "BYOS"

  features = {
    AZURE_DEVOPS_PROTECTION            = {}
    AZURE_DEVOPS_REPOSITORY_PROTECTION = {}
  }

  depends_on = [
    module.azure_exocompute,
    module.azure_tenant_devops,
  ]
}
