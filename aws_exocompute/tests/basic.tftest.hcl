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

run "setup_vpc" {
  state_key = "main"

  variables {
    name         = "aws_exocompute"
    public_cidr  = "172.22.0.0/24"
    subnet1_cidr = "172.22.1.0/24"
    subnet2_cidr = "172.22.2.0/24"
    vpc_cidr     = "172.22.0.0/16"
  }

  module {
    source = "./modules/vpc"
  }
}

run "setup_aws_cnp_account" {
  state_key = "main"

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
  state_key = "main"

  variables {
    cloud_account_id          = run.setup_aws_cnp_account.cloud_account_id
    region                    = "us-east-2"
    cluster_security_group_id = run.setup_vpc.cluster_security_group_id
    node_security_group_id    = run.setup_vpc.node_security_group_id
    subnet1_id                = run.setup_vpc.subnet1_id
    subnet2_id                = run.setup_vpc.subnet2_id
    vpc_id                    = run.setup_vpc.vpc_id
  }

  # polaris_aws_exocompute resource.
  assert {
    condition = polaris_aws_exocompute.exocompute.account_id == run.setup.cloud_account_id
    error_message = "The account ID does not match the expected value."
  }
}
