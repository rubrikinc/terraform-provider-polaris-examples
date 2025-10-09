locals {
  features = [
    "CLOUD_NATIVE_ARCHIVAL",
    "CLOUD_NATIVE_PROTECTION",
    "CLOUD_NATIVE_DYNAMODB_PROTECTION",
    "CLOUD_NATIVE_S3_PROTECTION",
    "EXOCOMPUTE",
    "RDS_PROTECTION",
    "SERVERS_AND_APPS",
  ]

  cloud_native_archival = [
    "BASIC",
  ]

  cloud_native_protection = [
    "BASIC",
  ]

  cloud_native_dynamodb_protection = [
    "BASIC",
  ]

  cloud_native_s3_protection = [
    "BASIC",
  ]

  exocompute = [
    "BASIC",
    "RSC_MANAGED_CLUSTER"
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
    error_message = "The AWS account ID must be a valid 12-digit AWS account ID."
  }
}

variable "account_name" {
  description = "AWS account name."
  type        = string
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

variable "external_id" {
  description = "AWS external ID. If empty, RSC will automatically generate an external ID."
  type        = string
  default     = null
}

variable "features" {
  description = "RSC features with permission groups. Possible features are: CLOUD_NATIVE_ARCHIVAL, CLOUD_NATIVE_DYNAMODB_PROTECTION, CLOUD_NATIVE_PROTECTION, CLOUD_NATIVE_S3_PROTECTION, EXOCOMPUTE, RDS_PROTECTION and SERVERS_AND_APPS."
  type = map(object({
    permission_groups = set(string)
  }))

  validation {
    condition     = length(setsubtract(keys(var.features), local.features)) == 0
    error_message = format("Invalid RSC feature. Allowed features are: %v.", local.features)
  }
  validation {
    condition     = length(setsubtract(try(var.features["CLOUD_NATIVE_ARCHIVAL"].permission_groups, []), local.cloud_native_archival)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.cloud_native_archival))
  }
  validation {
    condition     = length(setsubtract(try(var.features["CLOUD_NATIVE_PROTECTION"].permission_groups, []), local.cloud_native_protection)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.cloud_native_protection))
  }
  validation {
    condition     = length(setsubtract(try(var.features["CLOUD_NATIVE_DYNAMODB_PROTECTION"].permission_groups, []), local.cloud_native_dynamodb_protection)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.cloud_native_dynamodb_protection))
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
    condition     = startswith(var.role_path, "/") && endswith(var.role_path, "/")
    error_message = "Invalid AWS role path. The role path must start and end with '/'."
  }
}

variable "regions" {
  description = "AWS regions to onboard."
  type        = set(string)
}

variable "role_type" {
  description = "How the AWS policies should be attached to the IAM roles created for RSC. Possible values: `managed`, `inline` and `legacy`. `legacy` should only be used for backwards compatibility with previously onboarded AWS accounts."
  type        = string
  default     = "managed"

  validation {
    condition     = can(regex("legacy|inline|managed", lower(var.role_type)))
    error_message = "Invalid AWS IAM role type. Possible values: `managed`, `inline` and `legacy`."
  }
}

variable "tags" {
  description = "Tags to apply to AWS resources created."
  type        = map(string)
  default = {
    Environment = "test"
    Example     = "aws_cnp_account"
    Module      = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}
