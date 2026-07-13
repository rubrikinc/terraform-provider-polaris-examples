output "organization_id" {
  description = "RSC organization ID (UUID) for the onboarded Azure DevOps organization."
  value       = polaris_azure_devops_organization.org.id
}

output "onboarding_powershell_script" {
  description = "PowerShell onboarding script to run against the Azure DevOps organization out of band."
  value       = data.polaris_azure_devops_script.onboard.powershell_script
  sensitive   = true
}

output "onboarding_bash_script" {
  description = "Bash onboarding script to run against the Azure DevOps organization out of band."
  value       = data.polaris_azure_devops_script.onboard.bash_script
  sensitive   = true
}
