resource "polaris_sla_domain" "sla_domain" {
  name         = var.name
  description  = var.description
  object_types = var.object_types

  dynamic "hourly_schedule" {
    for_each = var.hourly_schedule != null ? [var.hourly_schedule] : []
    content {
      frequency      = hourly_schedule.value.frequency
      retention      = hourly_schedule.value.retention
      retention_unit = hourly_schedule.value.retention_unit
    }
  }

  dynamic "daily_schedule" {
    for_each = var.daily_schedule != null ? [var.daily_schedule] : []
    content {
      frequency      = daily_schedule.value.frequency
      retention      = daily_schedule.value.retention
      retention_unit = daily_schedule.value.retention_unit
    }
  }

  dynamic "weekly_schedule" {
    for_each = var.weekly_schedule != null ? [var.weekly_schedule] : []
    content {
      day_of_week    = weekly_schedule.value.day_of_week
      frequency      = weekly_schedule.value.frequency
      retention      = weekly_schedule.value.retention
      retention_unit = weekly_schedule.value.retention_unit
    }
  }

  dynamic "monthly_schedule" {
    for_each = var.monthly_schedule != null ? [var.monthly_schedule] : []
    content {
      day_of_month   = monthly_schedule.value.day_of_month
      frequency      = monthly_schedule.value.frequency
      retention      = monthly_schedule.value.retention
      retention_unit = monthly_schedule.value.retention_unit
    }
  }

  dynamic "archival" {
    for_each = var.archival
    content {
      archival_location_id = archival.value.archival_location_id
      threshold            = archival.value.threshold
      threshold_unit       = archival.value.threshold_unit

      dynamic "archival_tiering" {
        for_each = archival.value.archival_tiering != null ? [archival.value.archival_tiering] : []
        content {
          instant_tiering                    = archival_tiering.value.instant_tiering
          cold_storage_class                 = archival_tiering.value.cold_storage_class
          min_accessible_duration_in_seconds = archival_tiering.value.min_accessible_duration_in_seconds
          tier_existing_snapshots            = archival_tiering.value.tier_existing_snapshots
        }
      }
    }
  }

  dynamic "replication_spec" {
    for_each = var.replication_spec
    content {
      retention      = replication_spec.value.retention
      retention_unit = replication_spec.value.retention_unit
      aws_region     = replication_spec.value.aws_region
      azure_region   = replication_spec.value.azure_region

      dynamic "local_retention" {
        for_each = replication_spec.value.local_retention != null ? [replication_spec.value.local_retention] : []
        content {
          retention      = local_retention.value.retention
          retention_unit = local_retention.value.retention_unit
        }
      }

      dynamic "replication_pair" {
        for_each = replication_spec.value.replication_pair
        content {
          source_cluster = replication_pair.value.source_cluster
          target_cluster = replication_pair.value.target_cluster
        }
      }

      dynamic "cascading_archival" {
        for_each = replication_spec.value.cascading_archival
        content {
          archival_location_id    = cascading_archival.value.archival_location_id
          archival_threshold      = cascading_archival.value.archival_threshold
          archival_threshold_unit = cascading_archival.value.archival_threshold_unit
          frequency               = cascading_archival.value.frequency

          dynamic "archival_tiering" {
            for_each = cascading_archival.value.archival_tiering != null ? [cascading_archival.value.archival_tiering] : []
            content {
              instant_tiering                    = archival_tiering.value.instant_tiering
              cold_storage_class                 = archival_tiering.value.cold_storage_class
              min_accessible_duration_in_seconds = archival_tiering.value.min_accessible_duration_in_seconds
              tier_existing_snapshots            = archival_tiering.value.tier_existing_snapshots
            }
          }
        }
      }
    }
  }
}

# Create tag rules for automatic SLA domain assignment.
resource "polaris_tag_rule" "tag_rule" {
  for_each = { for tr in var.tag_rules : tr.name => tr }

  name              = each.value.name
  object_type       = each.value.object_type
  tag_key           = each.value.tag_key
  tag_value         = each.value.tag_all_values ? null : each.value.tag_value
  tag_all_values    = each.value.tag_all_values ? true : null
  cloud_account_ids = length(each.value.cloud_account_ids) > 0 ? each.value.cloud_account_ids : null
}

# Assign tag rules to the SLA domain.
resource "polaris_sla_domain_assignment" "tag_rule_assignment" {
  count = length(var.tag_rules) > 0 ? 1 : 0

  sla_domain_id = polaris_sla_domain.sla_domain.id
  object_ids    = [for tr in polaris_tag_rule.tag_rule : tr.id]
}
