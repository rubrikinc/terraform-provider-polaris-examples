# Test creating a weekly SLA domain.
run "weekly_sla_domain" {
  variables {
    name         = "test-weekly-sla"
    description  = "Test weekly SLA domain"
    object_types = ["AZURE_OBJECT_TYPE"]

    weekly_schedule = {
      day_of_week    = "MONDAY"
      frequency      = 1
      retention      = 4
      retention_unit = "WEEKS"
    }
  }

  # polaris_sla_domain.sla_domain.
  assert {
    condition     = polaris_sla_domain.sla_domain.name == var.name
    error_message = "The name field should match the specified name."
  }
  assert {
    condition     = length(polaris_sla_domain.sla_domain.weekly_schedule) == 1
    error_message = "The weekly schedule should be configured."
  }
  assert {
    condition     = polaris_sla_domain.sla_domain.weekly_schedule[0].day_of_week == var.weekly_schedule.day_of_week
    error_message = "The weekly schedule day of week should match the specified day."
  }
  assert {
    condition     = polaris_sla_domain.sla_domain.weekly_schedule[0].frequency == var.weekly_schedule.frequency
    error_message = "The weekly schedule frequency should match the specified frequency."
  }

  # Outputs.
  assert {
    condition     = output.sla_domain_id == polaris_sla_domain.sla_domain.id
    error_message = "The SLA domain ID output should match the ID of the SLA domain."
  }
}

