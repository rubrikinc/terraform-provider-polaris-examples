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
  default     = "daily-with-replication"
}

variable "source_cluster_name" {
  description = "Name of the source Rubrik cluster."
  type        = string
}

variable "target_cluster_name" {
  description = "Name of the target Rubrik cluster for replication."
  type        = string
}

# Look up the source cluster.
data "polaris_sla_source_cluster" "source" {
  name = var.source_cluster_name
}

# Look up the target cluster.
data "polaris_sla_source_cluster" "target" {
  name = var.target_cluster_name
}

# Create an RSC SLA domain with cross-cluster replication.
module "sla_domain" {
  source = "../.."

  name         = var.sla_name
  description  = "Daily backup with cross-cluster replication"
  object_types = ["VSPHERE_OBJECT_TYPE"]

  daily_schedule = {
    frequency      = 1
    retention      = 7
    retention_unit = "DAYS"
  }

  # Replicate to a secondary cluster with local retention.
  replication_spec = [{
    retention      = 7
    retention_unit = "DAYS"

    local_retention = {
      retention      = 7
      retention_unit = "DAYS"
    }

    replication_pair = [{
      source_cluster = data.polaris_sla_source_cluster.source.id
      target_cluster = data.polaris_sla_source_cluster.target.id
    }]
  }]
}

output "sla_domain_id" {
  description = "The ID of the created SLA domain."
  value       = module.sla_domain.sla_domain_id
}

