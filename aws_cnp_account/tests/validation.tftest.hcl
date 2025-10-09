test {
  parallel = true
}

variables {
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
    Environment = "test"
    Example     = "aws_cnp_account"
    Module      = "github.com/rubrikinc/terraform-provider-polaris-examples"
    TestSuite   = "validation"
  }
}

provider "aws" {
  region = "us-east-2"
}

run "cloud_type_invalid_type" {
  command = plan

  variables {
    cloud_type = "CLOUD"
  }
  expect_failures = [
    var.cloud_type
  ]
}

run "features_invalid_feature_name" {
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

run "role_path_no_slash_at_the_beginning" {
  command = plan

  variables {
    role_path = "application/component/"
  }
  expect_failures = [
    var.role_path
  ]
}

run "role_path_no_slash_at_the_end" {
  command = plan

  variables {
    role_path = "/application/component"
  }
  expect_failures = [
    var.role_path
  ]
}
