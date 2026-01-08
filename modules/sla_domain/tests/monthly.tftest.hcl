# Test creating a monthly SLA domain.
run "monthly_sla_domain" {
  variables {
    name         = "test-monthly-sla"
    description  = "Test monthly SLA domain"
    object_types = ["MSSQL_OBJECT_TYPE"]

    monthly_schedule = {
      day_of_month   = "FIRST_DAY"
      frequency      = 1
      retention      = 12
      retention_unit = "MONTHS"
    }
  }

  # polaris_sla_domain.sla_domain.
  assert {
    condition     = polaris_sla_domain.sla_domain.name == var.name
    error_message = "The name field should match the specified name."
  }
  assert {
    condition     = length(polaris_sla_domain.sla_domain.monthly_schedule) == 1
    error_message = "The monthly schedule should be configured."
  }
  assert {
    condition     = polaris_sla_domain.sla_domain.monthly_schedule[0].day_of_month == var.monthly_schedule.day_of_month
    error_message = "The monthly schedule day of month should match the specified day."
  }

  # Outputs.
  assert {
    condition     = output.sla_domain_id == polaris_sla_domain.sla_domain.id
    error_message = "The SLA domain ID output should match the ID of the SLA domain."
  }
}

