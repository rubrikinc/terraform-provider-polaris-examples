variables {
  cloud_account_name = "test-account"
  cluster_name       = "test-cluster"
  admin_email        = "admin@example.com"
  admin_password     = "TestPassword123!"
  vpc_id             = "vpc-12345678"
  subnet_id          = "subnet-12345678"
  region             = "us-west-2"

  tags = {
    test = "validation"
  }
}

run "cloud_account_name_is_null" {
  command = plan

  variables {
    cloud_account_name = null
  }

  expect_failures = [
    var.cloud_account_name,
  ]
}

run "cloud_account_name_is_empty" {
  command = plan

  variables {
    cloud_account_name = ""
  }

  expect_failures = [
    var.cloud_account_name,
  ]
}

run "cluster_name_is_null" {
  command = plan

  variables {
    cluster_name = null
  }

  expect_failures = [
    var.cluster_name,
  ]
}

run "cluster_name_is_empty" {
  command = plan

  variables {
    cluster_name = ""
  }

  expect_failures = [
    var.cluster_name,
  ]
}

run "admin_email_is_null" {
  command = plan

  variables {
    admin_email = null
  }

  expect_failures = [
    var.admin_email,
  ]
}

run "admin_email_is_empty" {
  command = plan

  variables {
    admin_email = ""
  }

  expect_failures = [
    var.admin_email,
  ]
}

run "admin_password_is_null" {
  command = plan

  variables {
    admin_password = null
  }

  expect_failures = [
    var.admin_password,
  ]
}

run "admin_password_is_empty" {
  command = plan

  variables {
    admin_password = ""
  }

  expect_failures = [
    var.admin_password,
  ]
}

run "vpc_id_is_null" {
  command = plan

  variables {
    vpc_id = null
  }

  expect_failures = [
    var.vpc_id,
  ]
}

run "vpc_id_is_empty" {
  command = plan

  variables {
    vpc_id = ""
  }

  expect_failures = [
    var.vpc_id,
  ]
}

run "subnet_id_is_null" {
  command = plan

  variables {
    subnet_id = null
  }

  expect_failures = [
    var.subnet_id,
  ]
}

run "subnet_id_is_empty" {
  command = plan

  variables {
    subnet_id = ""
  }

  expect_failures = [
    var.subnet_id,
  ]
}

run "ingress_prefix_list_and_cidr_both_specified" {
  command = plan

  variables {
    ingress_allowed_prefix_list_ids = ["pl-12345678"]
    ingress_allowed_cidr_blocks     = ["10.0.0.0/8"]
  }

  expect_failures = [
    var.ingress_allowed_prefix_list_ids,
  ]
}

run "egress_prefix_list_and_cidr_both_specified" {
  command = plan

  variables {
    egress_allowed_prefix_list_ids = ["pl-12345678"]
    egress_allowed_cidr_blocks     = ["10.0.0.0/8"]
  }

  expect_failures = [
    var.egress_allowed_prefix_list_ids,
  ]
}

# Test invalid instance type
run "instance_type_is_invalid" {
  command = plan

  variables {
    instance_type = "T3_LARGE"
  }

  expect_failures = [
    var.instance_type,
  ]
}

# Test all valid instance types
run "instance_type_m5_4xlarge" {
  command = plan

  variables {
    instance_type               = "M5_4XLARGE"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }
}

run "instance_type_m6i_2xlarge" {
  command = plan

  variables {
    instance_type               = "M6I_2XLARGE"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }
}

run "instance_type_m6i_4xlarge" {
  command = plan

  variables {
    instance_type               = "M6I_4XLARGE"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }
}

run "instance_type_m6i_8xlarge" {
  command = plan

  variables {
    instance_type               = "M6I_8XLARGE"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }
}

run "instance_type_r6i_4xlarge" {
  command = plan

  variables {
    instance_type               = "R6I_4XLARGE"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }
}

run "instance_type_m6a_2xlarge" {
  command = plan

  variables {
    instance_type               = "M6A_2XLARGE"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }
}

run "instance_type_m6a_4xlarge" {
  command = plan

  variables {
    instance_type               = "M6A_4XLARGE"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }
}

run "instance_type_m6a_8xlarge" {
  command = plan

  variables {
    instance_type               = "M6A_8XLARGE"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }
}

run "instance_type_r6a_4xlarge" {
  command = plan

  variables {
    instance_type               = "R6A_4XLARGE"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }
}

# Test invalid VM type
run "vm_type_is_invalid" {
  command = plan

  variables {
    vm_type                     = "SUPER_DENSE"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }

  expect_failures = [
    var.vm_type,
  ]
}

# Test all valid VM types
run "vm_type_standard" {
  command = plan

  variables {
    vm_type                     = "STANDARD"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }
}

run "vm_type_dense" {
  command = plan

  variables {
    vm_type                     = "DENSE"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }
}

run "vm_type_extra_dense" {
  command = plan

  variables {
    vm_type                     = "EXTRA_DENSE"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }
}

