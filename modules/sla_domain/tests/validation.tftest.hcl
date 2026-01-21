test {
  parallel = true
}

variables {
  name         = "test-sla"
  description  = "Test SLA domain"
  object_types = ["AWS_EC2_EBS_OBJECT_TYPE"]

  daily_schedule = {
    frequency      = 1
    retention      = 7
    retention_unit = "DAYS"
  }
}

run "name_is_null" {
  command = plan

  variables {
    name = null
  }

  expect_failures = [
    var.name,
  ]
}

run "name_is_empty" {
  command = plan

  variables {
    name = ""
  }

  expect_failures = [
    var.name,
  ]
}

run "object_types_is_null" {
  command = plan

  variables {
    object_types = null
  }

  expect_failures = [
    var.object_types,
  ]
}

run "object_types_is_empty" {
  command = plan

  variables {
    object_types = []
  }

  expect_failures = [
    var.object_types,
  ]
}

run "object_types_is_invalid" {
  command = plan

  variables {
    object_types = ["INVALID_OBJECT_TYPE"]
  }

  expect_failures = [
    var.object_types,
  ]
}

run "description_is_empty" {
  command = plan

  variables {
    description = ""
  }

  expect_failures = [
    var.description,
  ]
}

run "hourly_schedule_frequency_is_zero" {
  command = plan

  variables {
    daily_schedule = null
    hourly_schedule = {
      frequency      = 0
      retention      = 24
      retention_unit = "HOURS"
    }
  }

  expect_failures = [
    var.hourly_schedule,
  ]
}

run "daily_schedule_retention_is_zero" {
  command = plan

  variables {
    daily_schedule = {
      frequency      = 1
      retention      = 0
      retention_unit = "DAYS"
    }
  }

  expect_failures = [
    var.daily_schedule,
  ]
}

run "weekly_schedule_invalid_day_of_week" {
  command = plan

  variables {
    daily_schedule = null
    weekly_schedule = {
      day_of_week    = "INVALID_DAY"
      frequency      = 1
      retention      = 4
      retention_unit = "WEEKS"
    }
  }

  expect_failures = [
    var.weekly_schedule,
  ]
}

run "monthly_schedule_invalid_day_of_month" {
  command = plan

  variables {
    daily_schedule = null
    monthly_schedule = {
      day_of_month   = "INVALID_DAY"
      frequency      = 1
      retention      = 12
      retention_unit = "MONTHS"
    }
  }

  expect_failures = [
    var.monthly_schedule,
  ]
}

