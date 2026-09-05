# Basic test for AWS Cloud Cluster module
# Note: This test validates the module configuration but does not actually deploy
# a cloud cluster due to the time and cost involved (30-60 minutes deployment time).

variables {
  region    = "us-west-2"
  vpc_id    = "vpc-12345678"
  subnet_id = "subnet-12345678"

  tags = {
    test       = "basic"
    module     = "aws_cloud_cluster"
    repository = "terraform-provider-polaris-examples"
  }
}

# Test basic configuration with auto-created resources
run "cloud_cluster_basic_config" {
  command = plan

  variables {
    cloud_account_name = "test-aws-account"
    region             = var.region
    cluster_name       = "test-cluster"
    admin_email        = "admin@example.com"
    admin_password     = "RubrikGoForward!"
    vpc_id             = var.vpc_id
    subnet_id          = var.subnet_id

    # Use CIDR blocks for security groups
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }

  # Validate that local values are computed correctly
  assert {
    condition     = length(local.security_group_ids) > 0
    error_message = "Security group IDs should be populated."
  }

  assert {
    condition     = local.instance_profile_name != null && local.instance_profile_name != ""
    error_message = "Instance profile name should be populated."
  }

  assert {
    condition     = local.bucket_name != null && local.bucket_name != ""
    error_message = "Bucket name should be populated."
  }

  assert {
    condition     = can(regex(".*-rubrik-cluster.do.not.delete$", local.bucket_name))
    error_message = "Generated bucket name should end with '-rubrik-cluster.do.not.delete'."
  }
}

# Test configuration with existing resources
run "cloud_cluster_existing_resources" {
  command = plan

  variables {
    cloud_account_name    = "test-aws-account"
    region                = var.region
    cluster_name          = "test-cluster"
    admin_email           = "admin@example.com"
    admin_password        = "RubrikGoForward!"
    vpc_id                = var.vpc_id
    subnet_id             = var.subnet_id
    bucket_name           = "existing-bucket"
    instance_profile_name = "existing-profile"
    security_group_ids    = ["sg-12345678"]
  }

  # Validate that existing resources are used
  assert {
    condition     = local.bucket_name == "existing-bucket"
    error_message = "Should use provided bucket name."
  }

  assert {
    condition     = local.instance_profile_name == "existing-profile"
    error_message = "Should use provided instance profile name."
  }

  assert {
    condition     = length(local.security_group_ids) == 1 && local.security_group_ids[0] == "sg-12345678"
    error_message = "Should use provided security group IDs."
  }
}

# Test advanced configuration
run "cloud_cluster_advanced_config" {
  command = plan

  variables {
    cloud_account_name  = "test-aws-account"
    region              = var.region
    cluster_name        = "production-cluster"
    admin_email         = "admin@example.com"
    admin_password      = "RubrikGoForward!"
    vpc_id              = var.vpc_id
    subnet_id           = var.subnet_id
    num_nodes           = 5
    enable_immutability = true
    cdm_version         = "9.4.0-p2-30507"
    instance_type       = "M6I_4XLARGE"
    vm_type             = "EXTRA_DENSE"

    dns_name_servers   = ["10.0.0.2", "10.0.0.3"]
    dns_search_domains = ["example.com"]
    ntp_servers        = ["time.example.com"]

    use_placement_groups = true

    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }

  # Validate cluster configuration
  assert {
    condition     = polaris_aws_cloud_cluster.example.region == var.region
    error_message = "Cluster region should match the specified region."
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.use_placement_groups == true
    error_message = "Placement groups should be enabled."
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.cluster_config[0].num_nodes == 5
    error_message = "Number of nodes should be 5."
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.cluster_config[0].enable_immutability == true
    error_message = "Immutability should be enabled."
  }
}

# Test configuration with prefix lists for security groups
run "cloud_cluster_prefix_lists" {
  command = plan

  variables {
    cloud_account_name              = "test-aws-account"
    region                          = var.region
    cluster_name                    = "test-cluster-pl"
    admin_email                     = "admin@example.com"
    admin_password                  = "RubrikGoForward!"
    vpc_id                          = var.vpc_id
    subnet_id                       = var.subnet_id
    ingress_allowed_prefix_list_ids = ["pl-12345678"]
    egress_allowed_prefix_list_ids  = ["pl-87654321"]
  }

  assert {
    condition     = length(local.security_group_ids) > 0
    error_message = "Security group IDs should be populated when using prefix lists."
  }
}

# Test configuration with KMS encryption
run "cloud_cluster_with_kms" {
  command = plan

  variables {
    cloud_account_name          = "test-aws-account"
    region                      = var.region
    cluster_name                = "test-cluster-kms"
    admin_email                 = "admin@example.com"
    admin_password              = "RubrikGoForward!"
    vpc_id                      = var.vpc_id
    subnet_id                   = var.subnet_id
    kms_key_arn                 = "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }

  assert {
    condition     = local.bucket_name != null && local.bucket_name != ""
    error_message = "Bucket name should be populated when using KMS encryption."
  }
}

# Test configuration with keep_cluster_on_failure enabled
run "cloud_cluster_keep_on_failure" {
  command = plan

  variables {
    cloud_account_name          = "test-aws-account"
    region                      = var.region
    cluster_name                = "test-cluster-keep"
    admin_email                 = "admin@example.com"
    admin_password              = "RubrikGoForward!"
    vpc_id                      = var.vpc_id
    subnet_id                   = var.subnet_id
    keep_cluster_on_failure     = true
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.cluster_config[0].keep_cluster_on_failure == true
    error_message = "keep_cluster_on_failure should be enabled."
  }
}

# Test configuration without placement groups
run "cloud_cluster_no_placement_groups" {
  command = plan

  variables {
    cloud_account_name          = "test-aws-account"
    region                      = var.region
    cluster_name                = "test-cluster-no-pg"
    admin_email                 = "admin@example.com"
    admin_password              = "RubrikGoForward!"
    vpc_id                      = var.vpc_id
    subnet_id                   = var.subnet_id
    use_placement_groups        = false
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.use_placement_groups == false
    error_message = "Placement groups should be disabled."
  }
}

# Test configuration with different instance types
run "cloud_cluster_instance_types" {
  command = plan

  variables {
    cloud_account_name          = "test-aws-account"
    region                      = var.region
    cluster_name                = "test-cluster-instance"
    admin_email                 = "admin@example.com"
    admin_password              = "RubrikGoForward!"
    vpc_id                      = var.vpc_id
    subnet_id                   = var.subnet_id
    instance_type               = "M6I_2XLARGE"
    vm_type                     = "EXTRA_DENSE"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.vm_config[0].instance_type == "M6I_2XLARGE"
    error_message = "Instance type should be M6I_2XLARGE."
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.vm_config[0].vm_type == "EXTRA_DENSE"
    error_message = "VM type should be EXTRA_DENSE."
  }
}

# Test minimum configuration with 1 node
run "cloud_cluster_minimum_config" {
  command = plan

  variables {
    cloud_account_name          = "test-aws-account"
    region                      = var.region
    cluster_name                = "test-cluster-min"
    admin_email                 = "admin@example.com"
    admin_password              = "RubrikGoForward!"
    vpc_id                      = var.vpc_id
    subnet_id                   = var.subnet_id
    num_nodes                   = 1
    enable_immutability         = false
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.cluster_config[0].num_nodes == 1
    error_message = "Number of nodes should be 1."
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.cluster_config[0].enable_immutability == false
    error_message = "Immutability should be disabled."
  }
}

# Test VM configuration attributes
run "cloud_cluster_vm_config_validation" {
  command = plan

  variables {
    cloud_account_name          = "test-aws-account"
    region                      = var.region
    cluster_name                = "test-cluster-vm"
    admin_email                 = "admin@example.com"
    admin_password              = "RubrikGoForward!"
    vpc_id                      = var.vpc_id
    subnet_id                   = var.subnet_id
    cdm_version                 = "9.4.0-p2-30507"
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.vm_config[0].cdm_version == "9.4.0-p2-30507"
    error_message = "CDM version should match the specified version."
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.vm_config[0].vpc_id == var.vpc_id
    error_message = "VPC ID in vm_config should match the specified VPC ID."
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.vm_config[0].subnet_id == var.subnet_id
    error_message = "Subnet ID in vm_config should match the specified subnet ID."
  }

  assert {
    condition     = local.security_group_ids != null
    error_message = "Security group IDs should be populated."
  }
}

# Test DNS and NTP configuration
run "cloud_cluster_dns_ntp_config" {
  command = plan

  variables {
    cloud_account_name          = "test-aws-account"
    region                      = var.region
    cluster_name                = "test-cluster-dns"
    admin_email                 = "admin@example.com"
    admin_password              = "RubrikGoForward!"
    vpc_id                      = var.vpc_id
    subnet_id                   = var.subnet_id
    dns_name_servers            = ["1.1.1.1", "1.0.0.1"]
    dns_search_domains          = ["internal.example.com", "example.com"]
    ntp_servers                 = ["time1.example.com", "time2.example.com"]
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }

  assert {
    condition     = length(polaris_aws_cloud_cluster.example.cluster_config[0].dns_name_servers) == 2
    error_message = "Should have 2 DNS name servers configured."
  }

  assert {
    condition     = length(polaris_aws_cloud_cluster.example.cluster_config[0].dns_search_domains) == 2
    error_message = "Should have 2 DNS search domains configured."
  }

  assert {
    condition     = length(polaris_aws_cloud_cluster.example.cluster_config[0].ntp_servers) == 2
    error_message = "Should have 2 NTP servers configured."
  }
}

# Test cluster name and region configuration
run "cloud_cluster_name_region_validation" {
  command = plan

  variables {
    cloud_account_name          = "test-aws-account"
    region                      = "us-east-1"
    cluster_name                = "test-cluster-outputs"
    admin_email                 = "admin@example.com"
    admin_password              = "RubrikGoForward!"
    vpc_id                      = var.vpc_id
    subnet_id                   = var.subnet_id
    ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
    egress_allowed_cidr_blocks  = ["0.0.0.0/0"]
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.cluster_config[0].cluster_name == "test-cluster-outputs"
    error_message = "Cluster name should match the input."
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.region == "us-east-1"
    error_message = "Region should match the input."
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.vm_config[0].vpc_id == var.vpc_id
    error_message = "VPC ID should match the input."
  }

  assert {
    condition     = polaris_aws_cloud_cluster.example.vm_config[0].subnet_id == var.subnet_id
    error_message = "Subnet ID should match the input."
  }
}

