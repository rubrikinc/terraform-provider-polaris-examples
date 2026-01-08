# Test creating a basic daily SLA domain.
run "daily_sla_domain" {
  variables {
    name         = "test-daily-sla"
    description  = "Test daily SLA domain"
    object_types = ["AWS_EC2_EBS_OBJECT_TYPE"]

    daily_schedule = {
      frequency      = 1
      retention      = 7
      retention_unit = "DAYS"
    }
  }

  # polaris_sla_domain.sla_domain.
  assert {
    condition     = polaris_sla_domain.sla_domain.name == var.name
    error_message = "The name field should match the specified name."
  }
  assert {
    condition     = polaris_sla_domain.sla_domain.description == var.description
    error_message = "The description field should match the specified description."
  }
  assert {
    condition     = polaris_sla_domain.sla_domain.object_types == var.object_types
    error_message = "The object types field should match the specified object types."
  }
  assert {
    condition     = length(polaris_sla_domain.sla_domain.daily_schedule) == 1
    error_message = "The daily schedule should be configured."
  }
  assert {
    condition     = polaris_sla_domain.sla_domain.daily_schedule[0].frequency == var.daily_schedule.frequency
    error_message = "The daily schedule frequency should match the specified frequency."
  }
  assert {
    condition     = polaris_sla_domain.sla_domain.daily_schedule[0].retention == var.daily_schedule.retention
    error_message = "The daily schedule retention should match the specified retention."
  }
  assert {
    condition     = polaris_sla_domain.sla_domain.daily_schedule[0].retention_unit == var.daily_schedule.retention_unit
    error_message = "The daily schedule retention unit should match the specified retention unit."
  }

  # Outputs.
  assert {
    condition     = output.sla_domain_id == polaris_sla_domain.sla_domain.id
    error_message = "The SLA domain ID output should match the ID of the SLA domain."
  }
  assert {
    condition     = output.sla_domain_name == polaris_sla_domain.sla_domain.name
    error_message = "The SLA domain name output should match the name of the SLA domain."
  }
}

