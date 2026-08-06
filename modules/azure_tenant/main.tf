locals {
  # When app_id and app_secret are passed in we use an existing application,
  # otherwise we create a new application with the specified display_name.
  create_app = var.app_id == null

  # The application display name, defaulting to the standard RSC name when not
  # specified.
  display_name = coalesce(var.display_name, "Rubrik Security Cloud - Azure Protection")
}

data "azuread_client_config" "current" {}

data "azuread_domains" "aad_domains" {
  only_initial = true

  lifecycle {
    postcondition {
      condition     = length(self.domains) > 0
      error_message = "No tenant domains found in the Azure AD tenant."
    }
  }
}

resource "polaris_azure_service_principal" "service_principal" {
  app_id        = local.create_app ? azuread_application.application[0].client_id : var.app_id
  app_name      = local.create_app ? azuread_application.application[0].display_name : data.azuread_application.application[0].display_name
  app_secret    = local.create_app ? azuread_application_password.password[0].value : var.app_secret
  tenant_domain = data.azuread_domains.aad_domains.domains[0].domain_name
  tenant_id     = local.create_app ? azuread_service_principal.service_principal[0].application_tenant_id : data.azuread_service_principal.service_principal[0].application_tenant_id
  use_case      = var.use_case
}

# Give RSC some time to finalize the Azure tenant onboarding.
resource "time_sleep" "wait_for_rsc" {
  create_duration = "15s"

  depends_on = [
    polaris_azure_service_principal.service_principal,
  ]
}

check "domains" {
  assert {
    condition     = length(data.azuread_domains.aad_domains.domains) == 1
    error_message = format("Multiple tenant domains found, using: %s", data.azuread_domains.aad_domains.domains[0].domain_name)
  }
}
