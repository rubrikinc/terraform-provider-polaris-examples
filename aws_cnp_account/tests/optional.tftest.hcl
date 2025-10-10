variable "account_id" {
  type = string
}

variables {
  ec2_recovery_role_path = format("arn:aws:iam::%s:role/EC2-Recovery-Role", var.account_id)
  external_id            = "Unique-External-ID"
  role_path              = "/application/component/"

  features = {
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC",
      ]
    },
  }

  regions = [
    "us-east-2",
    "us-west-2",
  ]

  tags = {
    Environment = "test"
    Example     = "aws_cnp_account"
    Module      = "github.com/rubrikinc/terraform-provider-polaris-examples"
    TestSuite   = "optional"
  }
}

provider "aws" {
  region = "us-east-2"
}

run "init" {
  # polaris_aws_cnp_permissions data source.
  assert {
    condition = length(data.polaris_aws_cnp_permissions.permissions) == 1
    error_message = "The number of permissions instances does not match the expected value."
  }
  assert {
    condition = data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].ec2_recovery_role_path == var.ec2_recovery_role_path
    error_message = "The ec2 recovery role path does not match the expected value."
  }
  assert {
    condition = length(data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies) == 1
    error_message = "The number of customer managed policies does not match the expected value."
  }
  assert {
    condition = data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies[0].feature == "CLOUD_NATIVE_PROTECTION"
    error_message = "The customer managed policies feature does not match the expected value."
  }
  assert {
    condition = data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies[0].name == "EC2ProtectionPolicy"
    error_message = "The customer managed policies name does not match the expected value."
  }
  assert {
    # Check that the recovery role path is inside the policy.
    condition = can(regex(var.ec2_recovery_role_path, data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies[0].policy))
    error_message = "The customer managed policies policy does not match the expected value."
  }

  # polaris_aws_cnp_account resource.
  assert {
    condition = polaris_aws_cnp_account.account.external_id == var.external_id
    error_message = "The external ID does not match the expected value."
  }
  assert {
    # Check that the external ID is inside the trust policy.
    condition = can(regex(var.external_id, local.trust_policies["CROSSACCOUNT"]))
    error_message = "The policy does not match the expected value."
  }

  # aws_iam_role resource.
  assert {
    condition = length(local.roles) == 1
    error_message = "The number of role instances does not match the expected value."
  }
  assert {
    # Check that the role path has been set on the role.
    condition = local.roles["CROSSACCOUNT"].path == var.role_path
    error_message = "The path does not match the expected value."
  }
  assert {
    # Make sure the JSON documents are ordered and formatted the same way.
    condition = jsonencode(jsondecode(local.roles["CROSSACCOUNT"].assume_role_policy)) == jsonencode(jsondecode(local.trust_policies["CROSSACCOUNT"]))
    error_message = "The assume role policy does not match the expected value."
  }

  # aws_iam_policy resource.
  assert {
    condition = length(aws_iam_policy.customer_managed) == 1
    error_message = "The number of customer managed policy instances does not match the expected value."
  }
  assert {
    # Make sure the JSON documents are ordered and formatted the same way.
    condition = jsonencode(jsondecode(aws_iam_policy.customer_managed["EC2ProtectionPolicy"].policy)) == jsonencode(jsondecode(data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies[0].policy))
    error_message = "The customer mananged policy does not match the expected value."
  }
}
