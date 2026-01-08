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
  default     = "daily-with-archival"
}

variable "archival_location_name" {
  description = "Name of the AWS S3 archival location to use."
  type        = string
}

# Look up the archival location by name.
data "polaris_aws_archival_location" "s3" {
  name = var.archival_location_name
}

# Create an RSC SLA domain with archival to S3.
module "sla_domain" {
  source = "../.."

  name         = var.sla_name
  description  = "Daily backup with archival to S3 and Glacier tiering"
  object_types = ["AWS_EC2_EBS_OBJECT_TYPE"]

  daily_schedule = {
    frequency      = 1
    retention      = 30
    retention_unit = "DAYS"
  }

  # Archive snapshots to S3 after 7 days.
  # Note: archival_tiering is only supported for data center archival locations,
  # not cloud native archival locations like polaris_aws_archival_location.
  archival = [{
    archival_location_id = data.polaris_aws_archival_location.s3.id
    threshold            = 7
    threshold_unit       = "DAYS"
  }]
}

output "sla_domain_id" {
  description = "The ID of the created SLA domain."
  value       = module.sla_domain.sla_domain_id
}

