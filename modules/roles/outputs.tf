output "role_id" {
  description = "The custom role ID."
  value       = polaris_custom_role.role.id
}

output "role_name" {
  description = "The custom role name."
  value       = polaris_custom_role.role.name
}

output "user_assignment_ids" {
  description = "Map of user IDs to assignment IDs."
  value       = { for id, assignment in polaris_role_assignment.user : id => assignment.id }
}

output "sso_group_assignment_ids" {
  description = "Map of SSO group IDs to assignment IDs."
  value       = { for id, assignment in polaris_role_assignment.sso_group : id => assignment.id }
}
