terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.8.0-beta.5"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Path to the RSC service account file."
}

variable "cloud" {
  type        = string
  default     = "STANDARD"
  description = "AWS cloud type."
}

variable "ec2_recovery_role_path" {
  type        = string
  default     = ""
  description = "EC2 recovery role path."
}

variable "external_id" {
  type        = string
  default     = ""
  description = "External ID. If left empty, RSC will automatically generate an external ID."
}

variable "features" {
  type        = set(string)
  description = "RSC features."
}

variable "name" {
  type        = string
  description = "AWS account name."
}

variable "native_id" {
  type        = string
  description = "AWS account ID."
}

variable "role_path" {
  type        = string
  default     = "/"
  description = "AWS role path."
}

variable "regions" {
  type        = set(string)
  description = "AWS regions."
}

provider "aws" {
}

provider "polaris" {
  credentials = var.polaris_credentials
}

# Lookup the instance profiles and roles needed for the specified RSC features.
data "polaris_aws_cnp_artifacts" "artifacts" {
  cloud    = var.cloud
  features = var.features
}

# Lookup the permission set, customer managed policies and managed policies,
# for each role given the current set of features.
data "polaris_aws_cnp_permissions" "permissions" {
  for_each               = data.polaris_aws_cnp_artifacts.artifacts.role_keys
  cloud                  = data.polaris_aws_cnp_artifacts.artifacts.cloud
  ec2_recovery_role_path = var.ec2_recovery_role_path
  features               = data.polaris_aws_cnp_artifacts.artifacts.features
  role_key               = each.key
}

# Create the RSC AWS cloud account.
resource "polaris_aws_cnp_account" "account" {
  cloud       = data.polaris_aws_cnp_artifacts.artifacts.cloud
  external_id = var.external_id
  features    = data.polaris_aws_cnp_artifacts.artifacts.features
  name        = var.name
  native_id   = var.native_id
  regions     = var.regions
}

# Create a trust policy per IAM role.
resource "polaris_aws_cnp_account_trust_policy" "trust_policy" {
  for_each    = data.polaris_aws_cnp_artifacts.artifacts.role_keys
  account_id  = polaris_aws_cnp_account.account.id
  features    = polaris_aws_cnp_account.account.features
  external_id = polaris_aws_cnp_account.account.external_id
  role_key    = each.key
}

# Create the required IAM roles.
resource "aws_iam_role" "role" {
  for_each            = data.polaris_aws_cnp_artifacts.artifacts.role_keys
  assume_role_policy  = polaris_aws_cnp_account_trust_policy.trust_policy[each.key].policy
  managed_policy_arns = data.polaris_aws_cnp_permissions.permissions[each.key].managed_policies
  name_prefix         = "rubrik-${lower(each.key)}-"
  path                = var.role_path

  dynamic "inline_policy" {
    for_each = data.polaris_aws_cnp_permissions.permissions[each.key].customer_managed_policies
    content {
      name   = inline_policy.value["name"]
      policy = inline_policy.value["policy"]
    }
  }
}

# Create the required IAM instance profiles.
resource "aws_iam_instance_profile" "profile" {
  for_each    = data.polaris_aws_cnp_artifacts.artifacts.instance_profile_keys
  name_prefix = "rubrik-${lower(each.key)}-"
  role        = aws_iam_role.role[each.value].name
}

# Attach the instance profiles and the roles to the RSC cloud account.
resource "polaris_aws_cnp_account_attachments" "attachments" {
  account_id = polaris_aws_cnp_account.account.id
  features   = polaris_aws_cnp_account.account.features

  dynamic "instance_profile" {
    for_each = aws_iam_instance_profile.profile
    content {
      key  = instance_profile.key
      name = instance_profile.value["name"]
    }
  }

  dynamic "role" {
    for_each = aws_iam_role.role
    content {
      key = role.key
      arn = role.value["arn"]
    }
  }
}
