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
      version = "~>2.48.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.9.0-beta.7"
    }
  }
}

provider "azuread" {}

provider "polaris" {}

data "azuread_domains" "aad_domains" {
  only_initial = true
}

data "polaris_account" "account" {}

resource "azuread_application" "application" {
  display_name = "RSC application - ${data.polaris_account.account.name}"
  web {
    homepage_url = "https://${data.polaris_account.account.fqdn}/setup_azure"
  }
}

resource "azuread_service_principal" "service_principal" {
  client_id = azuread_application.application.client_id
}

resource "azuread_service_principal_password" "service_principal_secret" {
  service_principal_id = azuread_service_principal.service_principal.object_id
}

resource "polaris_azure_service_principal" "service_principal" {
  app_id        = azuread_application.application.client_id
  app_name      = azuread_application.application.display_name
  app_secret    = azuread_service_principal_password.service_principal_secret.value
  tenant_domain = data.azuread_domains.aad_domains.domains.0.domain_name
  tenant_id     = azuread_service_principal.service_principal.application_tenant_id
}

output "service_principal_object_id" {
  value = azuread_service_principal.service_principal.object_id
}
