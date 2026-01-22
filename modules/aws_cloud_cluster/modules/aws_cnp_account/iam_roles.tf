locals {
  customer_managed_policies = merge([
    for role_key, value in data.polaris_aws_cnp_permissions.permissions : {
      for policy in value.customer_managed_policies : policy.name => {
        role_key = role_key,
        policy   = policy.policy,
      }
    }
  ]...)
}

# Create the required IAM roles.
resource "aws_iam_role" "role" {
  for_each           = data.polaris_aws_cnp_artifacts.artifacts.role_keys
  assume_role_policy = polaris_aws_cnp_account_trust_policy.trust_policy[each.key].policy
  name_prefix        = "rubrik-${lower(each.key)}-"
  path               = var.role_path
}

# Create customer inline IAM policies an attach them to the IAM roles.
resource "aws_iam_role_policy" "policy" {
  for_each = local.customer_managed_policies
  name     = each.key
  policy   = each.value.policy
  role     = aws_iam_role.role[each.value.role_key].name
}

# Attach the AWS managed policies to the IAM roles.
resource "aws_iam_role_policy_attachments_exclusive" "policy_attachments" {
  for_each    = data.polaris_aws_cnp_permissions.permissions
  role_name   = aws_iam_role.role[each.key].name
  policy_arns = each.value.managed_policies
}

# Create the required IAM instance profiles.
resource "aws_iam_instance_profile" "profile" {
  for_each    = data.polaris_aws_cnp_artifacts.artifacts.instance_profile_keys
  name_prefix = "rubrik-${lower(each.key)}-"
  role        = aws_iam_role.role[each.value].name
}
