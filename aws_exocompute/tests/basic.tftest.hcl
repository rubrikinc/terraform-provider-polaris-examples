variables {
  tags = {
    Environment = "test"
    Example     = "aws_exocompute"
    Module      = "github.com/rubrikinc/terraform-provider-polaris-examples"
    TestSuite   = "basic"
  }
}

provider "aws" {
  region = "us-east-2"
}

run "setup_exocompute_vpc" {
  variables {
    name         = "aws_exocompute"
    public_cidr  = "172.22.0.0/24"
    subnet1_cidr = "172.22.1.0/24"
    subnet2_cidr = "172.22.2.0/24"
    vpc_cidr     = "172.22.0.0/16"
  }

  module {
    source = "./modules/exocompute_vpc"
  }
}

run "setup_aws_cnp_account" {
  variables {
    features = {
      EXOCOMPUTE = {
        permission_groups = [
          "BASIC",
          "RSC_MANAGED_CLUSTER",
        ]
      },
    }

    regions = [
      "us-east-2",
    ]
  }

  module {
    source = "../aws_cnp_account"
  }
}

run "init" {
  variables {
    cloud_account_id          = run.setup_aws_cnp_account.cloud_account_id
    cluster_security_group_id = run.setup_exocompute_vpc.cluster_security_group_id
    node_security_group_id    = run.setup_exocompute_vpc.node_security_group_id
    region                    = "us-east-2"
    subnet1_id                = run.setup_exocompute_vpc.subnet1_id
    subnet2_id                = run.setup_exocompute_vpc.subnet2_id
    vpc_id                    = run.setup_exocompute_vpc.vpc_id
  }

  # polaris_aws_exocompute resource.
  assert {
    condition = polaris_aws_exocompute.configuration.account_id == var.cloud_account_id
    error_message = "The account ID does not match the expected value."
  }
  assert {
    condition = polaris_aws_exocompute.configuration.cluster_security_group_id == var.cluster_security_group_id
    error_message = "The cluster security group ID does not match the expected value."
  }
  assert {
    condition = polaris_aws_exocompute.configuration.node_security_group_id == var.node_security_group_id
    error_message = "The node security group ID does not match the expected value."
  }
  assert {
    condition = polaris_aws_exocompute.configuration.region == var.region
    error_message = "The region does not match the expected value."
  }
  assert {
    condition = polaris_aws_exocompute.configuration.subnet1_id == var.subnet1_id
    error_message = "The subnet1 ID does not match the expected value."
  }
  assert {
    condition = polaris_aws_exocompute.configuration.subnet2_id == var.subnet2_id
    error_message = "The subnet2 ID does not match the expected value."
  }
  assert {
    condition = polaris_aws_exocompute.configuration.vpc_id == var.vpc_id
    error_message = "The vpc ID does not match the expected value."
  }
}
