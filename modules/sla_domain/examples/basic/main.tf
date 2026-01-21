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
  default     = "daily-backup-example"
}

# Create an RSC SLA domain with a daily backup schedule.
module "sla_domain" {
  source = "../.."

  name         = var.sla_name
  description  = "Example daily SLA domain with 7-day retention"
  object_types = ["AWS_EC2_EBS_OBJECT_TYPE"]

  daily_schedule = {
    frequency      = 1
    retention      = 7
    retention_unit = "DAYS"
  }
}

output "sla_domain_id" {
  description = "The ID of the created SLA domain."
  value       = module.sla_domain.sla_domain_id
}

