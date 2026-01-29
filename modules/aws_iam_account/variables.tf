locals {
  features = [
    "CLOUD_NATIVE_ARCHIVAL",
    "CLOUD_NATIVE_DYNAMODB_PROTECTION",
    "CLOUD_NATIVE_PROTECTION",
    "CLOUD_NATIVE_S3_PROTECTION",
    "EXOCOMPUTE",
    "KUBERNETES_PROTECTION",
    "RDS_PROTECTION",
    "SERVERS_AND_APPS",
  ]

  cloud_native_archival = [
    "BASIC",
  ]

  cloud_native_dynamodb_protection = [
    "BASIC",
  ]

  cloud_native_protection = [
    "BASIC",
  ]

  cloud_native_s3_protection = [
    "BASIC",
  ]

  exocompute = [
    "BASIC",
    "RSC_MANAGED_CLUSTER"
  ]

  kubernetes_protection = [
    "BASIC",
  ]

  rds_protection = [
    "BASIC",
  ]

  servers_and_apps = [
    "CLOUD_CLUSTER_ES",
  ]
}

variable "account_id" {
  description = "AWS account ID."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "Account ID must be a valid 12-digit AWS account ID."
  }
}

variable "account_name" {
  description = "AWS account name."
  type        = string

  validation {
    condition     = var.account_name != null && var.account_name != ""
    error_message = "Account name must be a non-empty string."
  }
}

variable "cloud_type" {
  description = "AWS cloud type. Possible values are: STANDARD, GOV. Defaults to STANDARD."
  type        = string
  default     = null

  validation {
    condition     = var.cloud_type == null || can(regex("STANDARD|GOV", var.cloud_type))
    error_message = "Invalid AWS cloud type. Allowed values are: STANDARD or GOV."
  }
}

variable "ec2_recovery_role_path" {
  description = "AWS EC2 recovery role path."
  type        = string
  default     = null
}

variable "exocompute_host_id" {
  description = "RSC cloud account ID (UUID) of the AWS account hosting Exocompute."
  type        = string
  default     = null

  validation {
    condition     = var.exocompute_host_id == null || (var.exocompute_host_id != local.uuid_null && can(regex(local.uuid_regex, var.exocompute_host_id)))
    error_message = "Invalid AWS Exocompute host ID. The Exocompute host ID should be the RSC cloud account ID (UUID) of the AWS account hosting Exocompute. The ID must be all lower case."
  }
}

variable "external_id" {
  description = "AWS external ID. If empty, RSC will automatically generate an external ID."
  type        = string
  default     = null

  validation {
    condition     = var.external_id == null || var.external_id != ""
    error_message = "External ID must be a non-empty string."
  }
}

variable "features" {
  description = "RSC features with permission groups. Possible features are: CLOUD_NATIVE_ARCHIVAL, CLOUD_NATIVE_DYNAMODB_PROTECTION, CLOUD_NATIVE_PROTECTION, CLOUD_NATIVE_S3_PROTECTION, EXOCOMPUTE, RDS_PROTECTION and SERVERS_AND_APPS."
  type = map(object({
    permission_groups = set(string)
  }))

  validation {
    condition     = var.features != null && length(var.features) > 0 && length(setsubtract(keys(var.features), local.features)) == 0
    error_message = format("Invalid RSC feature. Allowed features are: %v.", join(", ", local.features))
  }
  validation {
    condition     = length(setsubtract(try(var.features["CLOUD_NATIVE_ARCHIVAL"].permission_groups, []), local.cloud_native_archival)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.cloud_native_archival))
  }
  validation {
    condition     = length(setsubtract(try(var.features["CLOUD_NATIVE_DYNAMODB_PROTECTION"].permission_groups, []), local.cloud_native_dynamodb_protection)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.cloud_native_dynamodb_protection))
  }
  validation {
    condition     = length(setsubtract(try(var.features["CLOUD_NATIVE_PROTECTION"].permission_groups, []), local.cloud_native_protection)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.cloud_native_protection))
  }
  validation {
    condition     = length(setsubtract(try(var.features["CLOUD_NATIVE_S3_PROTECTION"].permission_groups, []), local.cloud_native_s3_protection)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.cloud_native_s3_protection))
  }
  validation {
    condition     = length(setsubtract(try(var.features["EXOCOMPUTE"].permission_groups, []), local.exocompute)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.exocompute))
  }
  validation {
    condition     = length(setsubtract(try(var.features["KUBERNETES_PROTECTION"].permission_groups, []), local.kubernetes_protection)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.kubernetes_protection))
  }
  validation {
    condition     = length(setsubtract(try(var.features["RDS_PROTECTION"].permission_groups, []), local.rds_protection)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.rds_protection))
  }
  validation {
    condition     = length(setsubtract(try(var.features["SERVERS_AND_APPS"].permission_groups, []), local.servers_and_apps)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.servers_and_apps))
  }
}

variable "role_path" {
  description = "AWS role path. Defaults to '/'."
  type        = string
  default     = "/"

  validation {
    condition     = var.role_path != null && startswith(var.role_path, "/") && endswith(var.role_path, "/")
    error_message = "Invalid AWS role path. The role path must start and end with '/'."
  }
}

variable "regions" {
  description = "AWS regions to onboard."
  type        = set(string)

  validation {
    condition     = var.regions != null && length(var.regions) > 0 && length(setsubtract(var.regions, data.aws_regions.regions.names)) == 0
    error_message = "Regions must be a non-empty set with valid AWS region names."
  }
}

variable "role_type" {
  description = "How the AWS policies should be attached to the IAM roles created for RSC. Possible values: `managed`, `inline` and `legacy`. `legacy` should only be used for backwards compatibility with previously onboarded AWS accounts."
  type        = string
  default     = "managed"

  validation {
    condition     = var.role_type != null && can(regex("legacy|inline|managed", lower(var.role_type)))
    error_message = "Invalid AWS IAM role type. Possible values: `managed`, `inline` and `legacy`."
  }
}

variable "tags" {
  description = "Tags to apply to AWS resources created."
  type        = map(string)
  default = {
    Module     = "aws_iam_account"
    Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}
