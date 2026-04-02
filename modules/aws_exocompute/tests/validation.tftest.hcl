test {
  parallel = true
}

variables {
  cloud_account_id          = "d7984bca-db40-40b9-98ef-c56c4aff6c23"
  cluster_access            = "EKS_CLUSTER_ACCESS_TYPE_PRIVATE"
  cluster_security_group_id = "sg-066288cc1e4a4be6a"
  node_security_group_id    = "sg-039a0f1da4fb1b806"
  pod_subnet1_id            = "subnet-1a260b5f755abddc9"
  pod_subnet2_id            = "subnet-2bdb0142c7604a6cc"
  region                    = "us-east-2"
  subnet1_id                = "subnet-1f260b5f755abddc9"
  subnet2_id                = "subnet-3edb0142c7604a6cc"
  vpc_id                    = "vpc-0e2a6d1bd6a5d8579"

  tags = {
    Environment = "test"
    Example     = "aws_exocompute"
    Module      = "github.com/rubrikinc/terraform-provider-polaris-examples"
    TestSuite   = "validation"
  }
}

run "variables_are_valid" {
  command = plan
}

run "variables_are_null" {
  command = plan

  variables {
    cloud_account_id          = null
    cluster_access            = null
    cluster_security_group_id = null
    node_security_group_id    = null
    pod_subnet1_id            = null
    pod_subnet2_id            = null
    region                    = null
    subnet1_id                = null
    subnet2_id                = null
    vpc_id                    = null
  }

  expect_failures = [
    var.cloud_account_id,
    var.region,
    var.subnet1_id,
    var.subnet2_id,
    var.vpc_id,
  ]
}

run "variables_are_empty" {
  command = plan

  variables {
    cloud_account_id          = ""
    cluster_access            = ""
    cluster_security_group_id = ""
    node_security_group_id    = ""
    pod_subnet1_id            = ""
    pod_subnet2_id            = ""
    region                    = ""
    subnet1_id                = ""
    subnet2_id                = ""
    vpc_id                    = ""
  }

  # Note, pod_subnet2_id have a dependency on pod_subnet1_id and will not be
  # validated after pod_subnet1_id fails validation.
  expect_failures = [
    var.cloud_account_id,
    var.cluster_access,
    var.cluster_security_group_id,
    var.node_security_group_id,
    var.pod_subnet1_id,
    var.region,
    var.subnet1_id,
    var.subnet2_id,
    var.vpc_id,
  ]
}

run "variables_are_invalid" {
  command = plan

  variables {
    cloud_account_id          = "d7984bca-db40-4Ob9-98ef-c56c4aff6c23"
    cluster_access            = "INVALID"
    cluster_security_group_id = "sg-O66288cc1e4a4be6a"
    node_security_group_id    = "sg-039a0f1da4fb1b8O6"
    pod_subnet1_id            = "subnet-1f26Ob5f755abddc9"
    pod_subnet2_id            = "subnet-3edb0142c76O4a6cc"
    region                    = "us-east2"
    subnet1_id                = "subnet-1f26Ob5f755abddc9"
    subnet2_id                = "subnet-3edb0142c76O4a6cc"
    vpc_id                    = "vpc-Oe2a6d1bd6a5d8579"
  }

  # Note, pod_subnet2_id have a dependency on pod_subnet1_id and will not be
  # validated after pod_subnet1_id fails validation.
  expect_failures = [
    var.cloud_account_id,
    var.cluster_access,
    var.cluster_security_group_id,
    var.node_security_group_id,
    var.pod_subnet1_id,
    var.region,
    var.subnet1_id,
    var.subnet2_id,
    var.vpc_id,
  ]
}

run "pod_subnets_are_not_paired" {
  command = plan

  variables {
    pod_subnet1_id = "subnet-1a260b5f755abddc9"
    pod_subnet2_id = null
  }

  expect_failures = [
    var.pod_subnet2_id,
  ]
}

run "cloud_account_id_is_null_uuid" {
  command = plan

  variables {
    cloud_account_id = "00000000-0000-0000-0000-000000000000"
  }

  expect_failures = [
    var.cloud_account_id
  ]
}
