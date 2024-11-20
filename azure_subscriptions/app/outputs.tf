output "principal_id" {
  value = azuread_service_principal.service_principal.object_id
}

output "tenant_domain" {
  value = polaris_azure_service_principal.service_principal.tenant_domain
}
