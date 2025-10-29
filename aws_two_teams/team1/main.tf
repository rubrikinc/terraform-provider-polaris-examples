locals {
  customer_managed_policies = merge([
    for key, value in data.polaris_aws_cnp_permissions.permissions : {
      for policy in value.customer_managed_policies : policy.name => {
        role_key = key,
        policy   = policy.policy,
      }
    }
  ]...)
}

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

output "permissions" {
  value = data.polaris_aws_cnp_permissions.permissions
}

resource "aws_iam_instance_profile" "profile" {
  for_each    = data.polaris_aws_cnp_artifacts.artifacts.instance_profile_keys
  name_prefix = "rubrik-${lower(each.key)}-"
  role        = aws_iam_role.role[each.value].name
  tags        = var.tags
}

resource "aws_iam_role" "role" {
  for_each           = data.polaris_aws_cnp_artifacts.artifacts.role_keys
  assume_role_policy = local.trust_policies[each.key]
  name_prefix        = "rubrik-${lower(each.key)}-"
  path               = var.role_path
  tags               = var.tags
}

resource "aws_iam_policy" "policy" {
  for_each    = local.customer_managed_policies
  name_prefix = "rubrik-${each.key}-"
  path        = var.role_path
  policy      = each.value.policy
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  for_each   = local.customer_managed_policies
  role       = aws_iam_role.role[each.value.role_key].name
  policy_arn = aws_iam_policy.policy[each.key].arn
}

resource "aws_iam_role_policy_attachments_exclusive" "policy_attachments_exclusive" {
  for_each  = data.polaris_aws_cnp_permissions.permissions
  role_name = aws_iam_role.role[each.key].name

  policy_arns = concat(
    each.value.managed_policies,
    [for policy in each.value.customer_managed_policies : aws_iam_policy.policy[policy.name].arn]
  )
}
