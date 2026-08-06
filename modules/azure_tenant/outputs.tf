# All outputs depend on the sleep to make sure that which ever output is used,
# there will be a delay giving RSC time to process the new tenant.

output "app_id" {
  description = "Application (client) ID of the Azure AD application."
  value       = polaris_azure_service_principal.service_principal.app_id

  depends_on = [
    time_sleep.wait_for_rsc
  ]
}

output "app_name" {
  description = "Display name of the Azure AD application."
  value       = polaris_azure_service_principal.service_principal.app_name

  depends_on = [
    time_sleep.wait_for_rsc
  ]
}

output "exocompute_group_id" {
  description = "Object ID of the Entra ID Exocompute group, or null when create_exocompute_group is false."
  value       = one(azuread_group.exocompute[*].object_id)

  depends_on = [
    time_sleep.wait_for_rsc
  ]
}

output "object_id" {
  description = "Object ID of the Azure AD service principal. This is the same ID used as principal_id in Azure RBAC role assignments."
  value       = local.service_principal_object_id

  depends_on = [
    time_sleep.wait_for_rsc
  ]
}

output "tenant_domain" {
  description = "Azure AD tenant primary domain."
  value       = polaris_azure_service_principal.service_principal.tenant_domain

  depends_on = [
    time_sleep.wait_for_rsc
  ]
}

output "tenant_id" {
  description = "Azure AD tenant ID."
  value       = polaris_azure_service_principal.service_principal.tenant_id

  depends_on = [
    time_sleep.wait_for_rsc
  ]
}
