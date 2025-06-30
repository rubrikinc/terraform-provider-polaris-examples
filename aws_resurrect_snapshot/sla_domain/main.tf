data "polaris_sla_domain" "sla_domain" {
  name = var.sla_domain_name
}

resource "polaris_tag_rule" "ec2_instances" {
  name           = var.tag_rule_name
  object_type    = "AWS_EC2_INSTANCE"
  tag_key        = var.tag_rule_tag
  tag_all_values = true
}

resource "polaris_sla_domain_assignment" "sla_domain_assignment" {
  sla_domain_id = data.polaris_sla_domain.sla_domain.id

  object_ids = [
    polaris_tag_rule.ec2_instances.id,
  ]
}
