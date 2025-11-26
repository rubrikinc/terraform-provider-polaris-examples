variable "account_id" {
  type = string
}

variable "account_name" {
  type = string
}

variables {
  features = {
    CLOUD_NATIVE_DYNAMODB_PROTECTION = {
      permission_groups = [
        "BASIC"
      ]
    },
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC",
      ]
    },
    CLOUD_NATIVE_S3_PROTECTION = {
      permission_groups = [
        "BASIC"
      ]
    },
    RDS_PROTECTION = {
      permission_groups = [
        "BASIC"
      ]
    },
  }

  regions = [
    "us-east-2",
    "us-west-2",
  ]

  tags = {
    Test       = "basic"
    Module     = "aws_iam_account"
    Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}

provider "aws" {
  region = "us-east-2"
}

run "aws_account" {
  # polaris_aws_cnp_artifacts data source.
  assert {
    condition     = data.polaris_aws_cnp_artifacts.artifacts.cloud == "STANDARD"
    error_message = "The cloud type does not match the expected value."
  }
  assert {
    condition     = length(data.polaris_aws_cnp_artifacts.artifacts.feature) == length(var.features)
    error_message = "The number of features does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(data.polaris_aws_cnp_artifacts.artifacts.feature.*.name, keys(var.features))) == 0
    error_message = "The feature names does not match the expected value."
  }
  assert {
    condition     = length(data.polaris_aws_cnp_artifacts.artifacts.role_keys) == 1
    error_message = "The number of role keys does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(data.polaris_aws_cnp_artifacts.artifacts.role_keys, ["CROSSACCOUNT"])) == 0
    error_message = "The role keys does not match the expected value."
  }
  assert {
    condition     = length(data.polaris_aws_cnp_artifacts.artifacts.instance_profile_keys) == 0
    error_message = "The instance profiles does not match the expected value."
  }

  # polaris_aws_cnp_permissions data source.
  assert {
    condition     = length(data.polaris_aws_cnp_permissions.permissions) == 1
    error_message = "The number of permissions instances does not match the expected value."
  }
  assert {
    condition     = data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].cloud == "STANDARD"
    error_message = "The cloud type does not match the expected value."
  }
  assert {
    condition     = data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].ec2_recovery_role_path == null
    error_message = "The ec2 recovery role path does not match the expected value."
  }
  assert {
    condition     = data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].role_key == "CROSSACCOUNT"
    error_message = "The role keys does not match the expected value."
  }
  assert {
    condition     = length(data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies) == 4
    error_message = "The number of customer managed policies does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies[*].feature, keys(var.features))) == 0
    error_message = "The customer managed policies features does not match the expected values."
  }
  assert {
    condition = length(setsubtract(data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies[*].name, [
      "DynamoDBProtectionPolicy", "EC2ProtectionPolicy", "S3ProtectionPolicy", "RDSProtectionPolicy"])) == 0
    error_message = "The customer managed policies names does not match the expected values."
  }
  assert {
    condition     = length([for p in data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies : p.policy if p.policy == ""]) == 0
    error_message = "The customer managed policies policies does not match the expected values."
  }
  assert {
    condition     = length(data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].managed_policies) == 0
    error_message = "The number of managed policies does not match the expected value."
  }

  # polaris_aws_cnp_account resource.
  assert {
    condition     = can(regex(local.uuid_regex, polaris_aws_cnp_account.account.id)) && polaris_aws_cnp_account.account.id != local.uuid_null
    error_message = "The resource ID does not match the expected value."
  }
  assert {
    condition     = polaris_aws_cnp_account.account.cloud == "STANDARD"
    error_message = "The cloud type does not match the expected value."
  }
  assert {
    condition     = polaris_aws_cnp_account.account.name == var.account_name
    error_message = "The name does not match the expected value."
  }
  assert {
    condition     = polaris_aws_cnp_account.account.native_id == var.account_id
    error_message = "The native ID does not match the expected value."
  }
  assert {
    condition     = length(polaris_aws_cnp_account.account.feature) == length(var.features)
    error_message = "The number of features does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(polaris_aws_cnp_account.account.feature.*.name, keys(var.features))) == 0
    error_message = "The features does not match the expected values."
  }
  assert {
    condition     = polaris_aws_cnp_account.account.external_id == var.external_id
    error_message = "The external ID does not match the expected value."
  }
  assert {
    condition     = length(polaris_aws_cnp_account.account.regions) == length(var.regions)
    error_message = "The number of regions does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(polaris_aws_cnp_account.account.regions, var.regions)) == 0
    error_message = "The regions does not match the expected value."
  }
  assert {
    condition     = length(polaris_aws_cnp_account.account.trust_policies) == 1
    error_message = "The number of trust policies does not match the expected value."
  }
  assert {
    condition     = one(polaris_aws_cnp_account.account.trust_policies.*.role_key) == "CROSSACCOUNT"
    error_message = "The trust policy role key does not match the expected value."
  }
  assert {
    condition     = one(polaris_aws_cnp_account.account.trust_policies.*.policy) != ""
    error_message = "The trust policy policy does not match the expected value."
  }

  # polaris_aws_cnp_account_attachments resource.
  assert {
    condition     = polaris_aws_cnp_account_attachments.attachments.id == polaris_aws_cnp_account.account.id
    error_message = "The resource ID does not match the expected value."
  }
  assert {
    condition     = polaris_aws_cnp_account_attachments.attachments.account_id == polaris_aws_cnp_account.account.id
    error_message = "The account ID does not match the expected value."
  }
  assert {
    condition     = length(polaris_aws_cnp_account_attachments.attachments.features) == 4
    error_message = "The number of features does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(polaris_aws_cnp_account_attachments.attachments.features, keys(var.features))) == 0
    error_message = "The features does not match the expected value."
  }
  assert {
    condition     = length(polaris_aws_cnp_account_attachments.attachments.instance_profile) == 0
    error_message = "The instance profile does not match the expected value."
  }
  assert {
    condition     = length(polaris_aws_cnp_account_attachments.attachments.role) == 1
    error_message = "The role does not match the expected value."
  }
  assert {
    condition     = one(polaris_aws_cnp_account_attachments.attachments.role.*.key) == "CROSSACCOUNT"
    error_message = "The role key does not match the expected value."
  }
  assert {
    condition     = one(polaris_aws_cnp_account_attachments.attachments.role.*.arn) == local.roles["CROSSACCOUNT"].arn
    error_message = "The role ARN does not match the expected value."
  }
  assert {
    condition     = length(one(polaris_aws_cnp_account_attachments.attachments.role.*.permissions)) == 64
    error_message = "The role permissions does not match the expected value."
  }

  # Outputs.
  assert {
    condition     = output.cloud_account_id == polaris_aws_cnp_account.account.id
    error_message = "The cloud account ID output does not match the expected value."
  }
}

run "aws_account_update_features" {
  variables {
    features = {
      EXOCOMPUTE = {
        permission_groups = [
          "BASIC",
          "RSC_MANAGED_CLUSTER",
        ]
      },
      RDS_PROTECTION = {
        permission_groups = [
          "BASIC",
        ]
      },
    }
  }

  # polaris_aws_cnp_artifacts data source.
  assert {
    condition     = length(data.polaris_aws_cnp_artifacts.artifacts.feature) == 2
    error_message = "The number of features does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(data.polaris_aws_cnp_artifacts.artifacts.feature.*.name, keys(var.features))) == 0
    error_message = "The feature names does not match the expected value."
  }
  assert {
    condition     = length(data.polaris_aws_cnp_artifacts.artifacts.role_keys) == 4
    error_message = "The number of role keys does not match the expected value."
  }
  assert {
    condition = length(setsubtract(data.polaris_aws_cnp_artifacts.artifacts.role_keys, [
      "CROSSACCOUNT", "EXOCOMPUTE_EKS_LAMBDA", "EXOCOMPUTE_EKS_MASTERNODE", "EXOCOMPUTE_EKS_WORKERNODE"])) == 0
    error_message = "The role keys does not match the expected value."
  }

  # polaris_aws_cnp_permissions data source.
  assert {
    condition     = length(data.polaris_aws_cnp_permissions.permissions) == 4
    error_message = "The number of permissions instances does not match the expected value."
  }
  assert {
    condition     = data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].role_key == "CROSSACCOUNT"
    error_message = "The role keys does not match the expected value."
  }
  assert {
    condition     = length(data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies) == 2
    error_message = "The number of customer managed policies does not match the expected value."
  }
  assert {
    condition = length(setsubtract(data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies[*].name, [
      "ExocomputePolicy", "RDSProtectionPolicy"])) == 0
    error_message = "The customer managed policies name does not match the expected values."
  }
  assert {
    condition     = length(data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].managed_policies) == 0
    error_message = "The number of managed policies does not match the expected value."
  }
  assert {
    condition     = data.polaris_aws_cnp_permissions.permissions["EXOCOMPUTE_EKS_MASTERNODE"].role_key == "EXOCOMPUTE_EKS_MASTERNODE"
    error_message = "The role keys does not match the expected value."
  }
  assert {
    condition     = length(data.polaris_aws_cnp_permissions.permissions["EXOCOMPUTE_EKS_MASTERNODE"].customer_managed_policies) == 0
    error_message = "The number of customer managed policies does not match the expected value."
  }
  assert {
    condition     = length(data.polaris_aws_cnp_permissions.permissions["EXOCOMPUTE_EKS_MASTERNODE"].managed_policies) == 1
    error_message = "The number of managed policies does not match the expected value."
  }
  assert {
    condition     = data.polaris_aws_cnp_permissions.permissions["EXOCOMPUTE_EKS_WORKERNODE"].role_key == "EXOCOMPUTE_EKS_WORKERNODE"
    error_message = "The role keys does not match the expected value."
  }
  assert {
    condition     = length(data.polaris_aws_cnp_permissions.permissions["EXOCOMPUTE_EKS_WORKERNODE"].customer_managed_policies) == 3
    error_message = "The number of customer managed policies does not match the expected value."
  }
  assert {
    condition = length(setsubtract(data.polaris_aws_cnp_permissions.permissions["EXOCOMPUTE_EKS_WORKERNODE"].customer_managed_policies[*].name, [
      "NodeRoleAutoscalingPolicy", "NodeRoleKMSPolicy", "NodeRoleSSMPolicy"])) == 0
    error_message = "The customer managed policies name does not match the expected values."
  }
  assert {
    condition     = length(data.polaris_aws_cnp_permissions.permissions["EXOCOMPUTE_EKS_WORKERNODE"].managed_policies) == 4
    error_message = "The number of managed policies does not match the expected value."
  }

  # polaris_aws_cnp_account resource.
  assert {
    # Make sure the account resource isn't recreated.
    condition     = polaris_aws_cnp_account.account.id == run.aws_account.cloud_account_id
    error_message = "The resource ID does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(polaris_aws_cnp_account.account.feature.*.name, keys(var.features))) == 0
    error_message = "The feature names does not match the expected value."
  }

  # polaris_aws_cnp_account_attachments resource.
  assert {
    condition     = length(polaris_aws_cnp_account_attachments.attachments.instance_profile) == 1
    error_message = "The instance profile does not match the expected value."
  }
  assert {
    condition     = one(polaris_aws_cnp_account_attachments.attachments.instance_profile.*.key) == "EXOCOMPUTE_EKS_WORKERNODE"
    error_message = "The role key does not match the expected value."
  }
  assert {
    condition     = one(polaris_aws_cnp_account_attachments.attachments.instance_profile.*.name) == aws_iam_instance_profile.profile["EXOCOMPUTE_EKS_WORKERNODE"].arn
    error_message = "The role ARN does not match the expected value."
  }
  assert {
    condition     = length(polaris_aws_cnp_account_attachments.attachments.role) == 4
    error_message = "The role does not match the expected value."
  }
  assert {
    condition = length(setsubtract(polaris_aws_cnp_account_attachments.attachments.role.*.key, [
      "CROSSACCOUNT", "EXOCOMPUTE_EKS_LAMBDA", "EXOCOMPUTE_EKS_MASTERNODE", "EXOCOMPUTE_EKS_WORKERNODE"])) == 0
    error_message = "The role key does not match the expected value."
  }
}

run "aws_account_update_name" {
  variables {
    account_name = "Updated Name"
  }

  # polaris_aws_cnp_account resource.
  assert {
    # Make sure the account resource isn't recreated.
    condition     = polaris_aws_cnp_account.account.id == run.aws_account.cloud_account_id
    error_message = "The resource ID does not match the expected value."
  }
  assert {
    condition     = polaris_aws_cnp_account.account.name == var.account_name
    error_message = "The name does not match the expected value."
  }
}

run "aws_account_update_regions" {
  variables {
    regions = concat(var.regions, ["eu-north-1"])
  }

  # polaris_aws_cnp_account resource.
  assert {
    # Make sure the account resource isn't recreated.
    condition     = polaris_aws_cnp_account.account.id == run.aws_account.cloud_account_id
    error_message = "The resource ID does not match the expected value."
  }
  assert {
    condition     = length(polaris_aws_cnp_account.account.regions) == length(var.regions)
    error_message = "The number of regions does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(polaris_aws_cnp_account.account.regions, var.regions)) == 0
    error_message = "The regions does not match the expected value."
  }
}
