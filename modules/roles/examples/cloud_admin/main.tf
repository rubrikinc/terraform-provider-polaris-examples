provider "polaris" {}

data "polaris_account" "all" {}

variable "aws_account_name" {
  description = "Name of the AWS account in RSC for EC2 and EBS workloads."
  type        = string
  default     = "aws-rubrikinc-intergrations-qa-dev"
}

variable "azure_subscription_name" {
  description = "Name of the Azure subscription in RSC."
  type        = string
  default     = "TrinityFDSE"
}

data "polaris_aws_account" "account" {
  name = var.aws_account_name
}

data "polaris_object" "azure_subscription" {
  name        = var.azure_subscription_name
  object_type = "AzureNativeSubscription"
}

locals {
  # Map each workload type to its ROOT object ID.
  workload_root = {
    "AwsNativeEc2Instance"      = "AWSNATIVE_ROOT"
    "AwsNativeEbsVolume"        = "AWSNATIVE_ROOT"
    "AwsNativeRdsInstance"      = "AWSNATIVE_ROOT"
    "AWS_NATIVE_S3_BUCKET"      = "AWSNATIVE_ROOT"
    "AWS_NATIVE_DYNAMODB_TABLE" = "AWSNATIVE_ROOT"
    "AzureNativeVirtualMachine" = "AZURENATIVE_ROOT"
    "AzureNativeManagedDisk"    = "AZURENATIVE_ROOT"
    "AzureSqlDatabaseDb"        = "AZURENATIVE_ROOT"
    "AzureSqlManagedInstanceDb" = "AZURENATIVE_ROOT"
    "AZURE_STORAGE_ACCOUNT"     = "AZURENATIVE_ROOT"
    "GcpNativeGCEInstance"      = "GCPNATIVE_ROOT"
    "GcpNativeDisk"             = "GCPNATIVE_ROOT"
  }

  # Map workload types to account-specific object IDs, falling back to ROOT.
  workload_account = merge(local.workload_root, {
    "AwsNativeEc2Instance"      = data.polaris_aws_account.account.id
    "AwsNativeEbsVolume"        = data.polaris_aws_account.account.id
    "AwsNativeRdsInstance"      = data.polaris_aws_account.account.id
    "AzureNativeVirtualMachine" = data.polaris_object.azure_subscription.id
    "AzureNativeManagedDisk"    = data.polaris_object.azure_subscription.id
    "AzureSqlDatabaseDb"        = data.polaris_object.azure_subscription.id
    "AzureSqlManagedInstanceDb" = data.polaris_object.azure_subscription.id
  })

  # Cloud workloads from the polaris_account data source.
  cloud_workloads = [
    for w in data.polaris_account.all.workloads : w
    if contains(keys(local.workload_root), w)
  ]

  # Mount-capable workload subset.
  mount_workload_set = toset([
    "AzureNativeVirtualMachine",
    "AzureNativeManagedDisk",
    "AZURE_STORAGE_ACCOUNT",
    "AWS_NATIVE_S3_BUCKET",
    "AWS_NATIVE_DYNAMODB_TABLE",
  ])
  mount_workloads = [for w in local.cloud_workloads : w if contains(local.mount_workload_set, w)]

  # Archival-capable workload subset.
  archival_workload_set = toset([
    "AZURE_STORAGE_ACCOUNT",
    "AWS_NATIVE_S3_BUCKET",
    "AWS_NATIVE_DYNAMODB_TABLE",
  ])
  archival_workloads = [for w in local.cloud_workloads : w if contains(local.archival_workload_set, w)]

  # Operations from the polaris_account data source, grouped by permission scope.
  provision_op_set = toset(["PROVISION_ON_INFRASTRUCTURE"])
  standard_op_set = toset([
    "VIEW_INVENTORY",
    "REFRESH_DATA_SOURCE",
    "MANAGE_PROTECTION",
    "TAKE_ON_DEMAND_SNAPSHOT",
    "DELETE_SNAPSHOT",
    "UPLOAD_SNAPSHOT_ON_DEMAND",
    "EXPORT_SNAPSHOTS",
    "DOWNLOAD",
    "RESTORE_TO_ORIGIN",
    "DOWNLOAD_SNAPSHOT_FROM_REPLICATION_TARGET",
    "MANAGE_DATA_SOURCE",
  ])
  mount_op_set    = toset(["MOUNT"])
  archival_op_set = toset(["DOWNLOAD_FROM_ARCHIVAL_LOCATION", "EXPORT_FILES"])
  sla_op_set      = toset(["VIEW_SLA"])

  provision_operations = [for op in data.polaris_account.all.operations : op if contains(local.provision_op_set, op)]
  standard_operations  = [for op in data.polaris_account.all.operations : op if contains(local.standard_op_set, op)]
  mount_operations     = [for op in data.polaris_account.all.operations : op if contains(local.mount_op_set, op)]
  archival_operations  = [for op in data.polaris_account.all.operations : op if contains(local.archival_op_set, op)]
  sla_operations       = [for op in data.polaris_account.all.operations : op if contains(local.sla_op_set, op)]
}

module "cloud_admin_role" {
  source = "../.."

  name = "cloud-admin"

  permissions = concat(
    # Provision operations use ROOT for all cloud workloads.
    [for op in local.provision_operations : {
      operation = op
      hierarchy = [for w in local.cloud_workloads : {
        snappable_type = w
        object_ids     = [local.workload_root[w]]
      }]
    }],

    # Standard operations use account-specific IDs.
    [for op in local.standard_operations : {
      operation = op
      hierarchy = [for w in local.cloud_workloads : {
        snappable_type = w
        object_ids     = [local.workload_account[w]]
      }]
    }],

    # Mount operations for mount-capable workloads.
    [for op in local.mount_operations : {
      operation = op
      hierarchy = [for w in local.mount_workloads : {
        snappable_type = w
        object_ids     = [local.workload_account[w]]
      }]
    }],

    # Archival operations for archival-capable workloads.
    [for op in local.archival_operations : {
      operation = op
      hierarchy = [for w in local.archival_workloads : {
        snappable_type = w
        object_ids     = [local.workload_root[w]]
      }]
    }],

    # SLA view operation.
    [for op in local.sla_operations : {
      operation = op
      hierarchy = [{
        snappable_type = "AllSubHierarchyType"
        object_ids     = ["DoNotProtect", "Inherit"]
      }]
    }],
  )
}

output "role_id" {
  description = "The ID of the created custom role."
  value       = module.cloud_admin_role.role_id
}
