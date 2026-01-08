output "sla_domain_id" {
  description = "RSC SLA domain ID (UUID)."
  value       = polaris_sla_domain.sla_domain.id
}

output "sla_domain_name" {
  description = "RSC SLA domain name."
  value       = polaris_sla_domain.sla_domain.name
}

output "tag_rule_ids" {
  description = "Map of tag rule names to their IDs (UUID)."
  value       = { for name, tr in polaris_tag_rule.tag_rule : name => tr.id }
}
