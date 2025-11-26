test {
  parallel = true
}

variables {
  account_id             = "123456789012"
  account_name           = "test-account"
  cloud_type             = "STANDARD"
  ec2_recovery_role_path = "/"
  external_id            = "Unique-External-ID"
  role_path              = "/application/component/"
  role_type              = "managed"

  features = {
    CLOUD_NATIVE_ARCHIVAL = {
      permission_groups = [
        "BASIC"
      ]
    },
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
    EXOCOMPUTE = {
      permission_groups = [
        "BASIC",
        "RSC_MANAGED_CLUSTER"
      ]
    },
    RDS_PROTECTION = {
      permission_groups = [
        "BASIC"
      ]
    },
    SERVERS_AND_APPS = {
      permission_groups = [
        "CLOUD_CLUSTER_ES"
      ]
    },
  }

  regions = [
    "us-east-2",
    "us-west-2",
  ]

  tags = {
    Test       = "validation"
    Module     = "aws_iam_account"
    Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}

provider "aws" {
  region = "us-east-2"
}

run "variables_are_valid" {
  command = plan
}

run "variables_are_null" {
  command = plan

  variables {
    account_id             = null
    account_name           = null
    cloud_type             = null
    ec2_recovery_role_path = null
    external_id            = null
    features               = null
    regions                = null
    role_path              = null
    role_type              = null
  }

  expect_failures = [
    var.account_id,
    var.account_name,
    var.features,
    var.regions,
    var.role_path,
    var.role_type,
  ]
}

run "variables_are_empty" {
  command = plan

  variables {
    account_id             = ""
    account_name           = ""
    cloud_type             = ""
    ec2_recovery_role_path = ""
    external_id            = ""
    features               = {}
    regions                = []
    role_path              = ""
    role_type              = ""
  }

  expect_failures = [
    var.account_id,
    var.account_name,
    var.cloud_type,
    var.external_id,
    var.features,
    var.regions,
    var.role_path,
    var.role_type,
  ]
}

run "variables_are_invalid" {
  command = plan

  variables {
    account_id = "123456789O123"
    cloud_type = "CLOUD"
    regions    = ["us-east-42"]
    role_path  = "application/component"
    role_type  = "modern"
  }

  expect_failures = [
    var.account_id,
    var.cloud_type,
    var.regions,
    var.role_path,
    var.role_type,
  ]
}

run "features_invalid_name" {
  command = plan

  variables {
    features = {
      CLOWN_NATIVE_PROTECTION = {
        permission_groups = [
          "BASIC",
        ]
      }
    }
  }
  expect_failures = [
    var.features
  ]
}

run "features_invalid_permission_group" {
  command = plan

  variables {
    features = {
      CLOUD_NATIVE_PROTECTION = {
        permission_groups = [
          "ADVANCED",
        ]
      }
    }
  }
  expect_failures = [
    var.features
  ]
}
