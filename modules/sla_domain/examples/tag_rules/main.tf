terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=1.4.0-beta.5"
    }
  }
}

variable "sla_name" {
  description = "Name of the SLA domain to create."
  type        = string
  default     = "production-ec2-backup"
}

# Create an RSC SLA domain with tag rules for automatic assignment.
# This example creates an SLA domain that automatically protects
# AWS EC2 instances tagged with environment=production.
module "sla_domain" {
  source = "../.."

  name         = var.sla_name
  description  = "Production EC2 backup with automatic tag-based assignment"
  object_types = ["AWS_EC2_EBS_OBJECT_TYPE"]

  daily_schedule = {
    frequency      = 1
    retention      = 30
    retention_unit = "DAYS"
  }

  # Tag rules for automatic SLA assignment.
  # Any AWS EC2 instance with tag environment=production will be
  # automatically protected by this SLA domain.
  tag_rules = [
    {
      name        = "aws-production-ec2"
      object_type = "AWS_EC2_INSTANCE"
      tag_key     = "environment"
      tag_value   = "production"
    }
  ]
}

output "sla_domain_id" {
  description = "The ID of the created SLA domain."
  value       = module.sla_domain.sla_domain_id
}

output "tag_rule_ids" {
  description = "Map of tag rule names to their IDs."
  value       = module.sla_domain.tag_rule_ids
}

