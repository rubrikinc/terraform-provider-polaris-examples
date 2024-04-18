# Example showing how to onboard an Azure service principal to RSC, independent
# of an Azure subscription.
#
# The credentials for Azure are read from the shell environment. The RSC service
# account is read from the RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS environment
# variable.

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.4.8"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.8.0"
    }
  }
}

variable "application_id" {
  type        = string
  description = "Azure application ID. Also known as client ID."
}

variable "application_secret" {
  type        = string
  description = "Azure application secret. Also known as client secret."
}

provider "azuread" {}

provider "polaris" {}

data "azuread_domains" "aad_domains" {
  only_initial = true
}

data "azuread_application" "application" {
  client_id = var.application_id
}

data "azuread_service_principal" "service_principal" {
  client_id = var.application_id
}

resource "polaris_azure_service_principal" "service_principal" {
  app_id        = data.azuread_application.application.client_id
  app_name      = data.azuread_application.application.display_name
  app_secret    = var.application_secret
  tenant_domain = data.azuread_domains.aad_domains.domains.0.domain_name
  tenant_id     = data.azuread_service_principal.service_principal.application_tenant_id
}
