output "organization_id" {
  description = "RSC organization ID (UUID) for the onboarded Azure DevOps organization."
  value       = polaris_azure_devops_organization.org.id
}
