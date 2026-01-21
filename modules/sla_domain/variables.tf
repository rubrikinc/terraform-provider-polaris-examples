locals {
  valid_object_types = [
    "ACTIVE_DIRECTORY_OBJECT_TYPE",
    "ATLASSIAN_JIRA_OBJECT_TYPE",
    "AWS_DYNAMODB_OBJECT_TYPE",
    "AWS_EC2_EBS_OBJECT_TYPE",
    "AWS_RDS_OBJECT_TYPE",
    "AWS_S3_OBJECT_TYPE",
    "AZURE_AD_OBJECT_TYPE",
    "AZURE_BLOB_OBJECT_TYPE",
    "AZURE_DEVOPS_OBJECT_TYPE",
    "AZURE_OBJECT_TYPE",
    "AZURE_SQL_DATABASE_OBJECT_TYPE",
    "AZURE_SQL_MANAGED_INSTANCE_OBJECT_TYPE",
    "CASSANDRA_OBJECT_TYPE",
    "D365_OBJECT_TYPE",
    "DB2_OBJECT_TYPE",
    "EXCHANGE_OBJECT_TYPE",
    "FILESET_OBJECT_TYPE",
    "GCP_CLOUD_SQL_OBJECT_TYPE",
    "GCP_OBJECT_TYPE",
    "GOOGLE_WORKSPACE_OBJECT_TYPE",
    "HYPERV_OBJECT_TYPE",
    "INFORMIX_INSTANCE_OBJECT_TYPE",
    "K8S_OBJECT_TYPE",
    "KUPR_OBJECT_TYPE",
    "M365_BACKUP_STORAGE_OBJECT_TYPE",
    "MANAGED_VOLUME_OBJECT_TYPE",
    "MONGO_OBJECT_TYPE",
    "MONGODB_OBJECT_TYPE",
    "MSSQL_OBJECT_TYPE",
    "MYSQLDB_OBJECT_TYPE",
    "NAS_OBJECT_TYPE",
    "NCD_OBJECT_TYPE",
    "NUTANIX_OBJECT_TYPE",
    "O365_OBJECT_TYPE",
    "OKTA_OBJECT_TYPE",
    "OLVM_OBJECT_TYPE",
    "OPENSTACK_OBJECT_TYPE",
    "ORACLE_OBJECT_TYPE",
    "POSTGRES_DB_CLUSTER_OBJECT_TYPE",
    "PROXMOX_OBJECT_TYPE",
    "SALESFORCE_OBJECT_TYPE",
    "SAP_HANA_OBJECT_TYPE",
    "SNAPMIRROR_CLOUD_OBJECT_TYPE",
    "VCD_OBJECT_TYPE",
    "VOLUME_GROUP_OBJECT_TYPE",
    "VSPHERE_OBJECT_TYPE",
  ]

  valid_retention_units          = ["DAYS", "WEEKS", "MONTHS", "YEARS"]
  valid_archival_retention_units = ["DAYS", "WEEKS", "MONTHS", "QUARTERS", "YEARS"]
  valid_days_of_week             = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]
  valid_days_of_month            = ["FIRST_DAY", "FIFTEENTH", "LAST_DAY"]
  valid_cold_storage_classes     = ["AWS_GLACIER", "AWS_GLACIER_DEEP_ARCHIVE", "AZURE_ARCHIVE"]
  uuid_regex                     = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
}

variable "name" {
  description = "SLA domain name."
  type        = string

  validation {
    condition     = var.name != null && var.name != ""
    error_message = "SLA domain name must be a non-empty string."
  }
}

variable "description" {
  description = "SLA domain description."
  type        = string
  default     = null

  validation {
    condition     = var.description == null || var.description != ""
    error_message = "Description must be a non-empty string."
  }
}

variable "object_types" {
  description = "Object types which can be protected by the SLA domain."
  type        = set(string)

  validation {
    condition     = var.object_types != null && length(var.object_types) > 0 && length(setsubtract(var.object_types, local.valid_object_types)) == 0
    error_message = format("Invalid object type(s). Allowed object types are: %v.", join(", ", local.valid_object_types))
  }
}

variable "hourly_schedule" {
  description = "Hourly snapshot schedule configuration."
  type = object({
    frequency      = number
    retention      = number
    retention_unit = optional(string, "DAYS")
  })
  default = null

  validation {
    condition     = var.hourly_schedule == null || (var.hourly_schedule.frequency >= 1 && var.hourly_schedule.retention >= 1)
    error_message = "Frequency and retention must be at least 1."
  }
}

variable "daily_schedule" {
  description = "Daily snapshot schedule configuration."
  type = object({
    frequency      = number
    retention      = number
    retention_unit = optional(string, "DAYS")
  })
  default = null

  validation {
    condition     = var.daily_schedule == null || (var.daily_schedule.frequency >= 1 && var.daily_schedule.retention >= 1)
    error_message = "Frequency and retention must be at least 1."
  }
}

variable "weekly_schedule" {
  description = "Weekly snapshot schedule configuration."
  type = object({
    day_of_week    = optional(string, "MONDAY")
    frequency      = number
    retention      = number
    retention_unit = optional(string, "DAYS")
  })
  default = null

  validation {
    condition     = var.weekly_schedule == null || (var.weekly_schedule.frequency >= 1 && var.weekly_schedule.retention >= 1)
    error_message = "Frequency and retention must be at least 1."
  }
  validation {
    condition     = var.weekly_schedule == null || contains(local.valid_days_of_week, var.weekly_schedule.day_of_week)
    error_message = format("Day of week must be one of: %v.", join(", ", local.valid_days_of_week))
  }
}

variable "monthly_schedule" {
  description = "Monthly snapshot schedule configuration."
  type = object({
    day_of_month   = string
    frequency      = number
    retention      = number
    retention_unit = optional(string, "DAYS")
  })
  default = null

  validation {
    condition     = var.monthly_schedule == null || (var.monthly_schedule.frequency >= 1 && var.monthly_schedule.retention >= 1)
    error_message = "Frequency and retention must be at least 1."
  }
  validation {
    condition     = var.monthly_schedule == null || contains(local.valid_days_of_month, var.monthly_schedule.day_of_month)
    error_message = format("Day of month must be one of: %v.", join(", ", local.valid_days_of_month))
  }
}

variable "archival" {
  description = <<-EOT
    Archival configuration for the SLA domain. Each archival entry specifies where to archive
    snapshots and when archival should occur.

    - archival_location_id: UUID of the archival location (use polaris_*_archival_location data sources)
    - threshold: Number of time units after which snapshots are archived (0 for instant archival)
    - threshold_unit: Unit of the threshold (DAYS, WEEKS, MONTHS, YEARS)
    - archival_tiering: Optional tiering configuration for cold storage
  EOT
  type = list(object({
    archival_location_id = string
    threshold            = optional(number, 0)
    threshold_unit       = optional(string, "DAYS")
    archival_tiering = optional(object({
      instant_tiering                    = optional(bool, false)
      cold_storage_class                 = optional(string)
      min_accessible_duration_in_seconds = optional(number, 0)
      tier_existing_snapshots            = optional(bool, false)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for a in var.archival : can(regex(local.uuid_regex, a.archival_location_id))
    ])
    error_message = "Archival location ID must be a valid UUID."
  }
  validation {
    condition = alltrue([
      for a in var.archival : a.threshold >= 0
    ])
    error_message = "Archival threshold must be at least 0 (0 for instant archival)."
  }
  validation {
    condition = alltrue([
      for a in var.archival : contains(local.valid_retention_units, a.threshold_unit)
    ])
    error_message = format("Threshold unit must be one of: %v.", join(", ", local.valid_retention_units))
  }
  validation {
    condition = alltrue([
      for a in var.archival : a.archival_tiering == null || (
        a.archival_tiering.cold_storage_class == null ||
        contains(local.valid_cold_storage_classes, a.archival_tiering.cold_storage_class)
      )
    ])
    error_message = format("Cold storage class must be one of: %v.", join(", ", local.valid_cold_storage_classes))
  }
}

variable "replication_spec" {
  description = <<-EOT
    Replication configuration for the SLA domain. Configures cross-cluster or cross-region replication.

    - retention: Retention period for replicated snapshots
    - retention_unit: Unit of retention (DAYS, WEEKS, MONTHS, YEARS)
    - aws_region: Optional AWS region for cross-region replication
    - azure_region: Optional Azure region for cross-region replication
    - local_retention: Optional local retention on target cluster
    - replication_pair: List of source/target cluster pairs for cross-cluster replication
    - cascading_archival: Optional archival from the replication target
  EOT
  type = list(object({
    retention      = number
    retention_unit = optional(string, "DAYS")
    aws_region     = optional(string)
    azure_region   = optional(string)
    local_retention = optional(object({
      retention      = number
      retention_unit = optional(string, "DAYS")
    }))
    replication_pair = optional(list(object({
      source_cluster = string
      target_cluster = string
    })), [])
    cascading_archival = optional(list(object({
      archival_location_id    = string
      archival_threshold      = optional(number)
      archival_threshold_unit = optional(string, "DAYS")
      frequency               = optional(set(string))
      archival_tiering = optional(object({
        instant_tiering                    = optional(bool, false)
        cold_storage_class                 = optional(string)
        min_accessible_duration_in_seconds = optional(number, 0)
        tier_existing_snapshots            = optional(bool, false)
      }))
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.replication_spec : r.retention >= 1
    ])
    error_message = "Replication retention must be at least 1."
  }
  validation {
    condition = alltrue([
      for r in var.replication_spec : contains(local.valid_retention_units, r.retention_unit)
    ])
    error_message = format("Retention unit must be one of: %v.", join(", ", local.valid_retention_units))
  }
  validation {
    condition = alltrue([
      for r in var.replication_spec : alltrue([
        for ca in r.cascading_archival : can(regex(local.uuid_regex, ca.archival_location_id))
      ])
    ])
    error_message = "Cascading archival location ID must be a valid UUID."
  }
  validation {
    condition = alltrue([
      for r in var.replication_spec : alltrue([
        for ca in r.cascading_archival : ca.archival_threshold_unit == null || contains(local.valid_archival_retention_units, ca.archival_threshold_unit)
      ])
    ])
    error_message = format("Archival threshold unit must be one of: %v.", join(", ", local.valid_archival_retention_units))
  }
}

variable "tag_rules" {
  description = <<-EOT
    Tag rules for automatic SLA domain assignment. Each tag rule matches cloud resources
    based on their tags and automatically assigns them to this SLA domain.

    - name: Unique name for the tag rule
    - object_type: Cloud object type to match (e.g., AWS_EC2_INSTANCE, AZURE_VIRTUAL_MACHINE)
    - tag_key: Tag key to match (case sensitive)
    - tag_value: Tag value to match (optional, use tag_all_values=true to match any value)
    - tag_all_values: If true, match all values for the tag key
    - cloud_account_ids: Optional list of RSC cloud account IDs to limit the rule scope
  EOT
  type = list(object({
    name              = string
    object_type       = string
    tag_key           = string
    tag_value         = optional(string)
    tag_all_values    = optional(bool, false)
    cloud_account_ids = optional(set(string), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for tr in var.tag_rules : tr.name != null && tr.name != ""
    ])
    error_message = "Tag rule name must be a non-empty string."
  }
  validation {
    condition = alltrue([
      for tr in var.tag_rules : tr.tag_key != null && tr.tag_key != ""
    ])
    error_message = "Tag key must be a non-empty string."
  }
  validation {
    condition = alltrue([
      for tr in var.tag_rules : (tr.tag_value != null && tr.tag_value != "") || tr.tag_all_values == true
    ])
    error_message = "Either tag_value must be specified or tag_all_values must be true."
  }
  validation {
    condition = alltrue([
      for tr in var.tag_rules : contains([
        "AWS_EBS_VOLUME",
        "AWS_EC2_INSTANCE",
        "AWS_RDS_INSTANCE",
        "AWS_S3_BUCKET",
        "AWS_DYNAMODB_TABLE",
        "AZURE_MANAGED_DISK",
        "AZURE_SQL_DATABASE_DB",
        "AZURE_SQL_DATABASE_SERVER",
        "AZURE_SQL_MANAGED_INSTANCE_SERVER",
        "AZURE_STORAGE_ACCOUNT",
        "AZURE_VIRTUAL_MACHINE",
      ], tr.object_type)
    ])
    error_message = "Invalid object type. Allowed values are: AWS_EBS_VOLUME, AWS_EC2_INSTANCE, AWS_RDS_INSTANCE, AWS_S3_BUCKET, AWS_DYNAMODB_TABLE, AZURE_MANAGED_DISK, AZURE_SQL_DATABASE_DB, AZURE_SQL_DATABASE_SERVER, AZURE_SQL_MANAGED_INSTANCE_SERVER, AZURE_STORAGE_ACCOUNT, AZURE_VIRTUAL_MACHINE."
  }
  validation {
    condition = alltrue([
      for tr in var.tag_rules : alltrue([
        for id in tr.cloud_account_ids : can(regex(local.uuid_regex, id))
      ])
    ])
    error_message = "Cloud account IDs must be valid UUIDs."
  }
}
