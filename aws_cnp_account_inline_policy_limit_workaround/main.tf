# Example showing how to onboard an AWS account to RSC without using a
# CloudFormation stack. RSC will authenticate to AWS using a cross-account role
# created by the configuration. This example does not use inline policies to
# avoid the 10,240 bytes limit.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.70.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.0.0"
    }
  }
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
  type = map(object({
    permission_groups = set(string)
  }))
  description = "RSC features with permission groups."
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

provider "aws" {}

provider "polaris" {}

# Lookup the instance profiles and roles needed for the specified RSC features.
data "polaris_aws_cnp_artifacts" "artifacts" {
  cloud = var.cloud

  dynamic "feature" {
    for_each = var.features
    content {
      name              = feature.key
      permission_groups = feature.value["permission_groups"]
    }
  }
}

# Lookup the permission set, customer managed policies and managed policies,
# for each role given the current set of features.
data "polaris_aws_cnp_permissions" "permissions" {
  for_each               = data.polaris_aws_cnp_artifacts.artifacts.role_keys
  cloud                  = var.cloud
  ec2_recovery_role_path = var.ec2_recovery_role_path
  role_key               = each.key

  dynamic "feature" {
    for_each = var.features
    content {
      name              = feature.key
      permission_groups = feature.value["permission_groups"]
    }
  }
}

# Create the RSC AWS cloud account.
resource "polaris_aws_cnp_account" "account" {
  cloud       = var.cloud
  external_id = var.external_id
  name        = var.name
  native_id   = var.native_id
  regions     = var.regions

  dynamic "feature" {
    for_each = var.features
    content {
      name              = feature.key
      permission_groups = feature.value["permission_groups"]
    }
  }
}

# Create a trust policy per IAM role.
resource "polaris_aws_cnp_account_trust_policy" "trust_policy" {
  for_each    = data.polaris_aws_cnp_artifacts.artifacts.role_keys
  account_id  = polaris_aws_cnp_account.account.id
  features    = keys(var.features)
  external_id = var.external_id
  role_key    = each.key
}


# Attach the instance profiles and the roles to the RSC cloud account.
resource "polaris_aws_cnp_account_attachments" "attachments" {
  account_id = polaris_aws_cnp_account.account.id
  features   = keys(var.features)

  dynamic "instance_profile" {
    for_each = aws_iam_instance_profile.profile
    content {
      key  = instance_profile.key
      name = instance_profile.value["arn"]
    }
  }

  dynamic "role" {
    for_each = aws_iam_role.role
    content {
      key         = role.key
      arn         = role.value["arn"]
      permissions = data.polaris_aws_cnp_permissions.permissions[role.key].id
    }
  }
}
