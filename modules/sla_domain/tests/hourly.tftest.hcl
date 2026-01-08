# Test creating an hourly SLA domain.
run "hourly_sla_domain" {
  variables {
    name         = "test-hourly-sla"
    description  = "Test hourly SLA domain"
    object_types = ["VSPHERE_OBJECT_TYPE"]

    hourly_schedule = {
      frequency      = 4
      retention      = 24
      retention_unit = "HOURS"
    }
  }

  # polaris_sla_domain.sla_domain.
  assert {
    condition     = polaris_sla_domain.sla_domain.name == var.name
    error_message = "The name field should match the specified name."
  }
  assert {
    condition     = length(polaris_sla_domain.sla_domain.hourly_schedule) == 1
    error_message = "The hourly schedule should be configured."
  }
  assert {
    condition     = polaris_sla_domain.sla_domain.hourly_schedule[0].frequency == var.hourly_schedule.frequency
    error_message = "The hourly schedule frequency should match the specified frequency."
  }
  assert {
    condition     = polaris_sla_domain.sla_domain.hourly_schedule[0].retention == var.hourly_schedule.retention
    error_message = "The hourly schedule retention should match the specified retention."
  }

  # Outputs.
  assert {
    condition     = output.sla_domain_id == polaris_sla_domain.sla_domain.id
    error_message = "The SLA domain ID output should match the ID of the SLA domain."
  }
}

