# Lookup the instance profiles and roles needed for the specified RSC features.
data "polaris_aws_cnp_artifacts" "artifacts" {
  cloud = var.cloud_type

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
  cloud                  = var.cloud_type
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
  cloud       = var.cloud_type
  external_id = var.external_id
  name        = var.account_name
  native_id   = var.account_id
  regions     = var.regions

  dynamic "feature" {
    for_each = var.features
    content {
      name              = feature.key
      permission_groups = feature.value["permission_groups"]
    }
  }
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
    for_each = local.roles
    content {
      key         = role.key
      arn         = role.value["arn"]
      permissions = data.polaris_aws_cnp_permissions.permissions[role.key].id
    }
  }
}

# Give RSC some time to finalize the AWS account onboarding.
resource "time_sleep" "wait_for_rsc" {
  create_duration = "20s"

  depends_on = [
    polaris_aws_cnp_account_attachments.attachments,
  ]
}
