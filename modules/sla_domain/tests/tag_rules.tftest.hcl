# Test creating an SLA domain with tag rules.
run "sla_domain_with_tag_rules" {
  variables {
    name         = "test-sla-with-tags"
    description  = "Test SLA domain with tag rules"
    object_types = ["AWS_EC2_EBS_OBJECT_TYPE"]

    daily_schedule = {
      frequency      = 1
      retention      = 7
      retention_unit = "DAYS"
    }

    tag_rules = [
      {
        name        = "test-aws-ec2-rule"
        object_type = "AWS_EC2_INSTANCE"
        tag_key     = "backup"
        tag_value   = "true"
      },
      {
        name           = "test-aws-ebs-rule"
        object_type    = "AWS_EBS_VOLUME"
        tag_key        = "environment"
        tag_all_values = true
      }
    ]
  }

  # polaris_sla_domain.sla_domain.
  assert {
    condition     = polaris_sla_domain.sla_domain.name == var.name
    error_message = "The SLA domain name should match the specified name."
  }

  # polaris_tag_rule.tag_rule - check that 2 tag rules are created.
  assert {
    condition     = length(polaris_tag_rule.tag_rule) == 2
    error_message = "Two tag rules should be created."
  }

  # Verify first tag rule.
  assert {
    condition     = polaris_tag_rule.tag_rule["test-aws-ec2-rule"].name == "test-aws-ec2-rule"
    error_message = "The first tag rule name should match."
  }
  assert {
    condition     = polaris_tag_rule.tag_rule["test-aws-ec2-rule"].object_type == "AWS_EC2_INSTANCE"
    error_message = "The first tag rule object type should be AWS_EC2_INSTANCE."
  }
  assert {
    condition     = polaris_tag_rule.tag_rule["test-aws-ec2-rule"].tag_key == "backup"
    error_message = "The first tag rule tag key should be 'backup'."
  }
  assert {
    condition     = polaris_tag_rule.tag_rule["test-aws-ec2-rule"].tag_value == "true"
    error_message = "The first tag rule tag value should be 'true'."
  }

  # Verify second tag rule with tag_all_values.
  assert {
    condition     = polaris_tag_rule.tag_rule["test-aws-ebs-rule"].name == "test-aws-ebs-rule"
    error_message = "The second tag rule name should match."
  }
  assert {
    condition     = polaris_tag_rule.tag_rule["test-aws-ebs-rule"].object_type == "AWS_EBS_VOLUME"
    error_message = "The second tag rule object type should be AWS_EBS_VOLUME."
  }
  assert {
    condition     = polaris_tag_rule.tag_rule["test-aws-ebs-rule"].tag_key == "environment"
    error_message = "The second tag rule tag key should be 'environment'."
  }
  assert {
    condition     = polaris_tag_rule.tag_rule["test-aws-ebs-rule"].tag_all_values == true
    error_message = "The second tag rule should match all tag values."
  }

  # polaris_sla_domain_assignment.tag_rule_assignment - verify assignment exists.
  assert {
    condition     = length(polaris_sla_domain_assignment.tag_rule_assignment) == 1
    error_message = "One SLA domain assignment should be created."
  }
  assert {
    condition     = polaris_sla_domain_assignment.tag_rule_assignment[0].sla_domain_id == polaris_sla_domain.sla_domain.id
    error_message = "The assignment should reference the correct SLA domain."
  }
  assert {
    condition     = length(polaris_sla_domain_assignment.tag_rule_assignment[0].object_ids) == 2
    error_message = "The assignment should include both tag rules."
  }

  # Outputs.
  assert {
    condition     = output.sla_domain_id == polaris_sla_domain.sla_domain.id
    error_message = "The SLA domain ID output should match."
  }
  assert {
    condition     = length(output.tag_rule_ids) == 2
    error_message = "The tag rule IDs output should contain 2 entries."
  }
  assert {
    condition     = output.tag_rule_ids["test-aws-ec2-rule"] == polaris_tag_rule.tag_rule["test-aws-ec2-rule"].id
    error_message = "The tag rule ID output should match the first tag rule ID."
  }
  assert {
    condition     = output.tag_rule_ids["test-aws-ebs-rule"] == polaris_tag_rule.tag_rule["test-aws-ebs-rule"].id
    error_message = "The tag rule ID output should match the second tag rule ID."
  }
}

# Test SLA domain without tag rules (tag_rule_ids should be empty).
run "sla_domain_without_tag_rules" {
  variables {
    name         = "test-sla-no-tags"
    description  = "Test SLA domain without tag rules"
    object_types = ["AWS_EC2_EBS_OBJECT_TYPE"]

    daily_schedule = {
      frequency      = 1
      retention      = 7
      retention_unit = "DAYS"
    }
  }

  # Verify no tag rules are created.
  assert {
    condition     = length(polaris_tag_rule.tag_rule) == 0
    error_message = "No tag rules should be created when tag_rules is empty."
  }

  # Verify no assignment is created.
  assert {
    condition     = length(polaris_sla_domain_assignment.tag_rule_assignment) == 0
    error_message = "No SLA domain assignment should be created when tag_rules is empty."
  }

  # Outputs.
  assert {
    condition     = length(output.tag_rule_ids) == 0
    error_message = "The tag rule IDs output should be empty."
  }
}

