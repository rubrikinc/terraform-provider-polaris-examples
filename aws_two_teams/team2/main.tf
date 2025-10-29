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

data "polaris_aws_cnp_permissions" "permissions" {
  for_each = data.polaris_aws_cnp_artifacts.artifacts.role_keys
  cloud    = var.cloud_type
  role_key = each.key

  dynamic "feature" {
    for_each = var.features
    content {
      name              = feature.key
      permission_groups = feature.value["permission_groups"]
    }
  }
}

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

resource "polaris_aws_cnp_account_attachments" "attachments" {
  account_id = polaris_aws_cnp_account.account.id
  features   = keys(var.features)

  dynamic "instance_profile" {
    for_each = var.instance_profiles
    content {
      key  = instance_profile.key
      name = instance_profile.value
    }
  }

  dynamic "role" {
    for_each = var.roles
    content {
      key         = role.key
      arn         = role.value
      permissions = data.polaris_aws_cnp_permissions.permissions[role.key].id
    }
  }
}

resource "time_sleep" "wait_for_rsc" {
  create_duration = "20s"

  depends_on = [
    polaris_aws_cnp_account_attachments.attachments,
  ]
}
