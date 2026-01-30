# SLA Domain Module

This module manages RSC global SLA Domains. An SLA Domain defines how you want to take snapshots of objects like
virtual machines, databases, SaaS apps and cloud objects. This module supports creating SLA Domains with hourly,
daily, weekly, and monthly snapshot schedules.

> [!NOTE]
> The module validates that the specified object types are valid. If the validation fails, Terraform will produce an
> error during the plan/apply phase.

> [!NOTE]
> For workloads backed up on a Rubrik cluster, snapshots are scheduled using the time zone of that Rubrik cluster.
> For workloads backed up in the cloud, snapshots are scheduled using the UTC time zone.

## Usage

### Basic Daily SLA Domain

```terraform
module "sla_domain" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/sla_domain"

  name         = "daily-backup"
  description  = "Daily backup with 7-day retention"
  object_types = ["AWS_EC2_EBS_OBJECT_TYPE"]

  daily_schedule = {
    frequency      = 1
    retention      = 7
    retention_unit = "DAYS"
  }
}
```

### Hourly SLA Domain

```terraform
module "sla_domain" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/sla_domain"

  name         = "hourly-backup"
  description  = "Hourly backup with 24-hour retention"
  object_types = ["VSPHERE_OBJECT_TYPE"]

  hourly_schedule = {
    frequency      = 1
    retention      = 24
    retention_unit = "HOURS"
  }
}
```

### Weekly SLA Domain

```terraform
module "sla_domain" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/sla_domain"

  name         = "weekly-backup"
  description  = "Weekly backup every Monday with 4-week retention"
  object_types = ["AZURE_OBJECT_TYPE"]

  weekly_schedule = {
    day_of_week    = "MONDAY"
    frequency      = 1
    retention      = 4
    retention_unit = "WEEKS"
  }
}
```

### Multiple Schedules

```terraform
module "sla_domain" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/sla_domain"

  name         = "comprehensive-backup"
  description  = "Comprehensive backup policy with multiple schedules"
  object_types = ["VSPHERE_OBJECT_TYPE", "HYPERV_OBJECT_TYPE"]

  hourly_schedule = {
    frequency      = 4
    retention      = 24
    retention_unit = "HOURS"
  }

  daily_schedule = {
    frequency      = 1
    retention      = 7
    retention_unit = "DAYS"
  }

  weekly_schedule = {
    day_of_week    = "SUNDAY"
    frequency      = 1
    retention      = 4
    retention_unit = "WEEKS"
  }

  monthly_schedule = {
    day_of_month   = "FIRST_DAY"
    frequency      = 1
    retention      = 12
    retention_unit = "MONTHS"
  }
}
```

### SLA Domain with Archival

```terraform
data "polaris_aws_archival_location" "s3" {
  name = "my-s3-archival-location"
}

module "sla_domain" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/sla_domain"

  name         = "daily-with-archival"
  description  = "Daily backup with archival to S3"
  object_types = ["AWS_EC2_EBS_OBJECT_TYPE"]

  daily_schedule = {
    frequency      = 1
    retention      = 30
    retention_unit = "DAYS"
  }

  # Note: archival_tiering is only supported for data center archival locations,
  # not cloud native archival locations like polaris_aws_archival_location.
  archival = [{
    archival_location_id = data.polaris_aws_archival_location.s3.id
    threshold            = 7
    threshold_unit       = "DAYS"
  }]
}
```

### SLA Domain with Cross-Cluster Replication

```terraform
data "polaris_sla_source_cluster" "source" {
  name = "SOURCE-CLUSTER"
}

data "polaris_sla_source_cluster" "target" {
  name = "TARGET-CLUSTER"
}

module "sla_domain" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/sla_domain"

  name         = "daily-with-replication"
  description  = "Daily backup with cross-cluster replication"
  object_types = ["VSPHERE_OBJECT_TYPE"]

  daily_schedule = {
    frequency      = 1
    retention      = 7
    retention_unit = "DAYS"
  }

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
```

### SLA Domain with Replication and Cascading Archival

```terraform
data "polaris_sla_source_cluster" "source" {
  name = "SOURCE-CLUSTER"
}

data "polaris_sla_source_cluster" "target" {
  name = "TARGET-CLUSTER"
}

data "polaris_data_center_archival_location" "archive" {
  cluster_id = data.polaris_sla_source_cluster.target.id
  name       = "My Archival Location"
}

module "sla_domain" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/sla_domain"

  name         = "replication-with-cascading-archival"
  description  = "Cross-cluster replication with cascading archival"
  object_types = ["VSPHERE_OBJECT_TYPE"]

  daily_schedule = {
    frequency      = 1
    retention      = 7
    retention_unit = "DAYS"
  }

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

    cascading_archival = [{
      archival_location_id    = data.polaris_data_center_archival_location.archive.id
      archival_threshold      = 7
      archival_threshold_unit = "DAYS"
      frequency               = ["DAYS"]

      archival_tiering = {
        instant_tiering                    = true
        cold_storage_class                 = "AZURE_ARCHIVE"
        min_accessible_duration_in_seconds = 86400
      }
    }]
  }]
}
```

### SLA Domain with Tag Rules

```terraform
module "sla_domain" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/sla_domain"

  name         = "production-backup"
  description  = "Production workloads backup policy"
  object_types = ["AWS_EC2_EBS_OBJECT_TYPE", "AZURE_OBJECT_TYPE"]

  daily_schedule = {
    frequency      = 1
    retention      = 30
    retention_unit = "DAYS"
  }

  tag_rules = [
    {
      name        = "aws-production-ec2"
      object_type = "AWS_EC2_INSTANCE"
      tag_key     = "environment"
      tag_value   = "production"
    },
    {
      name        = "azure-production-vms"
      object_type = "AZURE_VIRTUAL_MACHINE"
      tag_key     = "environment"
      tag_value   = "production"
    },
    {
      name           = "aws-backup-enabled"
      object_type    = "AWS_EC2_INSTANCE"
      tag_key        = "backup"
      tag_all_values = true
    }
  ]
}
```

## Examples

- [Basic Example](examples/basic) - Simple daily SLA domain
- [Archival Example](examples/archival) - Daily backup with S3 archival and Glacier tiering
- [Cross-Cluster Replication Example](examples/cross_cluster_replication) - Replication between Rubrik clusters
- [Cascading Archival Example](examples/cascading_archival) - Replication with archival from target cluster
- [Tag Rules Example](examples/tag_rules) - Automatic SLA assignment based on cloud resource tags

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.11.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | =1.4.0-beta.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | =1.4.0-beta.5 |

## Resources

| Name | Type |
|------|------|
| [polaris_sla_domain.sla_domain](https://registry.terraform.io/providers/rubrikinc/polaris/1.4.0-beta.5/docs/resources/sla_domain) | resource |
| [polaris_sla_domain_assignment.tag_rule_assignment](https://registry.terraform.io/providers/rubrikinc/polaris/1.4.0-beta.5/docs/resources/sla_domain_assignment) | resource |
| [polaris_tag_rule.tag_rule](https://registry.terraform.io/providers/rubrikinc/polaris/1.4.0-beta.5/docs/resources/tag_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_archival"></a> [archival](#input\_archival) | Archival configuration for the SLA domain. Each archival entry specifies where to archive<br/>snapshots and when archival should occur.<br/><br/>- archival\_location\_id: UUID of the archival location (use polaris\_*\_archival\_location data sources)<br/>- threshold: Number of time units after which snapshots are archived (0 for instant archival)<br/>- threshold\_unit: Unit of the threshold (DAYS, WEEKS, MONTHS, YEARS)<br/>- archival\_tiering: Optional tiering configuration for cold storage | <pre>list(object({<br/>    archival_location_id = string<br/>    threshold            = optional(number, 0)<br/>    threshold_unit       = optional(string, "DAYS")<br/>    archival_tiering = optional(object({<br/>      instant_tiering                    = optional(bool, false)<br/>      cold_storage_class                 = optional(string)<br/>      min_accessible_duration_in_seconds = optional(number, 0)<br/>      tier_existing_snapshots            = optional(bool, false)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_daily_schedule"></a> [daily\_schedule](#input\_daily\_schedule) | Daily snapshot schedule configuration. | <pre>object({<br/>    frequency      = number<br/>    retention      = number<br/>    retention_unit = optional(string, "DAYS")<br/>  })</pre> | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | SLA domain description. | `string` | `null` | no |
| <a name="input_hourly_schedule"></a> [hourly\_schedule](#input\_hourly\_schedule) | Hourly snapshot schedule configuration. | <pre>object({<br/>    frequency      = number<br/>    retention      = number<br/>    retention_unit = optional(string, "DAYS")<br/>  })</pre> | `null` | no |
| <a name="input_monthly_schedule"></a> [monthly\_schedule](#input\_monthly\_schedule) | Monthly snapshot schedule configuration. | <pre>object({<br/>    day_of_month   = string<br/>    frequency      = number<br/>    retention      = number<br/>    retention_unit = optional(string, "DAYS")<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | SLA domain name. | `string` | n/a | yes |
| <a name="input_object_types"></a> [object\_types](#input\_object\_types) | Object types which can be protected by the SLA domain. | `set(string)` | n/a | yes |
| <a name="input_replication_spec"></a> [replication\_spec](#input\_replication\_spec) | Replication configuration for the SLA domain. Configures cross-cluster or cross-region replication.<br/><br/>- retention: Retention period for replicated snapshots<br/>- retention\_unit: Unit of retention (DAYS, WEEKS, MONTHS, YEARS)<br/>- aws\_region: Optional AWS region for cross-region replication<br/>- azure\_region: Optional Azure region for cross-region replication<br/>- local\_retention: Optional local retention on target cluster<br/>- replication\_pair: List of source/target cluster pairs for cross-cluster replication<br/>- cascading\_archival: Optional archival from the replication target | <pre>list(object({<br/>    retention      = number<br/>    retention_unit = optional(string, "DAYS")<br/>    aws_region     = optional(string)<br/>    azure_region   = optional(string)<br/>    local_retention = optional(object({<br/>      retention      = number<br/>      retention_unit = optional(string, "DAYS")<br/>    }))<br/>    replication_pair = optional(list(object({<br/>      source_cluster = string<br/>      target_cluster = string<br/>    })), [])<br/>    cascading_archival = optional(list(object({<br/>      archival_location_id    = string<br/>      archival_threshold      = optional(number)<br/>      archival_threshold_unit = optional(string, "DAYS")<br/>      frequency               = optional(set(string))<br/>      archival_tiering = optional(object({<br/>        instant_tiering                    = optional(bool, false)<br/>        cold_storage_class                 = optional(string)<br/>        min_accessible_duration_in_seconds = optional(number, 0)<br/>        tier_existing_snapshots            = optional(bool, false)<br/>      }))<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_tag_rules"></a> [tag\_rules](#input\_tag\_rules) | Tag rules for automatic SLA domain assignment. Each tag rule matches cloud resources<br/>based on their tags and automatically assigns them to this SLA domain.<br/><br/>- name: Unique name for the tag rule<br/>- object\_type: Cloud object type to match (e.g., AWS\_EC2\_INSTANCE, AZURE\_VIRTUAL\_MACHINE)<br/>- tag\_key: Tag key to match (case sensitive)<br/>- tag\_value: Tag value to match (optional, use tag\_all\_values=true to match any value)<br/>- tag\_all\_values: If true, match all values for the tag key<br/>- cloud\_account\_ids: Optional list of RSC cloud account IDs to limit the rule scope | <pre>list(object({<br/>    name              = string<br/>    object_type       = string<br/>    tag_key           = string<br/>    tag_value         = optional(string)<br/>    tag_all_values    = optional(bool, false)<br/>    cloud_account_ids = optional(set(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_weekly_schedule"></a> [weekly\_schedule](#input\_weekly\_schedule) | Weekly snapshot schedule configuration. | <pre>object({<br/>    day_of_week    = optional(string, "MONDAY")<br/>    frequency      = number<br/>    retention      = number<br/>    retention_unit = optional(string, "DAYS")<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sla_domain_id"></a> [sla\_domain\_id](#output\_sla\_domain\_id) | RSC SLA domain ID (UUID). |
| <a name="output_sla_domain_name"></a> [sla\_domain\_name](#output\_sla\_domain\_name) | RSC SLA domain name. |
| <a name="output_tag_rule_ids"></a> [tag\_rule\_ids](#output\_tag\_rule\_ids) | Map of tag rule names to their IDs (UUID). |
<!-- END_TF_DOCS -->

