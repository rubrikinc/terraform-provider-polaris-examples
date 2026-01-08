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
  default     = "replication-with-cascading-archival"
}

variable "source_cluster_name" {
  description = "Name of the source Rubrik cluster."
  type        = string
}

variable "target_cluster_name" {
  description = "Name of the target Rubrik cluster for replication."
  type        = string
}

variable "archival_location_name" {
  description = "Name of the archival location on the target cluster."
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

# Look up the archival location on the target cluster.
data "polaris_data_center_archival_location" "archive" {
  cluster_id = data.polaris_sla_source_cluster.target.id
  name       = var.archival_location_name
}

# Create an RSC SLA domain with replication and cascading archival.
module "sla_domain" {
  source = "../.."

  name         = var.sla_name
  description  = "Cross-cluster replication with cascading archival from target"
  object_types = ["VSPHERE_OBJECT_TYPE"]

  daily_schedule = {
    frequency      = 1
    retention      = 7
    retention_unit = "DAYS"
  }

  # Replicate to secondary cluster, then archive from the target.
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

    # Archive from the replication target after 7 days.
    cascading_archival = [{
      archival_location_id    = data.polaris_data_center_archival_location.archive.id
      archival_threshold      = 7
      archival_threshold_unit = "DAYS"
      frequency               = ["DAYS"]

      archival_tiering = {
        instant_tiering                    = false
        cold_storage_class                 = "AZURE_ARCHIVE"
        min_accessible_duration_in_seconds = 86400
      }
    }]
  }]
}

output "sla_domain_id" {
  description = "The ID of the created SLA domain."
  value       = module.sla_domain.sla_domain_id
}

