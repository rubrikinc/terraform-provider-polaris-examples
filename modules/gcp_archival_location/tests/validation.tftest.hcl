test {
  parallel = true
}

variables {
  bucket_prefix = "test-prefix"
  name          = "test-name"
  region        = "us-central1"
  storage_class = "COLDLINE"

  bucket_labels = {
    label = "value"
  }

  # Note, these variables cannot have valid values, otherwise we need a valid
  # project and cloud account setup.
  cloud_account_id      = null
  customer_managed_keys = null
}

run "variables_are_null" {
  command = plan

  variables {
    bucket_labels = null
    bucket_prefix = null
    name          = null
    region        = null
    storage_class = null
  }

  expect_failures = [
    var.bucket_prefix,
    var.cloud_account_id,
    var.name,
    var.storage_class,
  ]
}

run "variables_are_empty" {
  command = plan

  variables {
    bucket_labels    = {}
    bucket_prefix    = ""
    cloud_account_id = ""
    name             = ""
    region           = ""
    storage_class    = ""
  }

  expect_failures = [
    var.bucket_prefix,
    var.cloud_account_id,
    var.name,
    var.region,
    var.storage_class,
  ]
}

run "bucket_prefix_is_too_long" {
  command = plan

  variables {
    bucket_prefix = "this-prefix-is-way-too-long-to-be-valid"
  }

  expect_failures = [
    var.bucket_prefix,
    var.cloud_account_id,
  ]
}

run "cloud_account_id_is_invalid" {
  command = plan

  variables {
    cloud_account_id = "not-a-valid-uuid"
  }

  expect_failures = [
    var.cloud_account_id,
  ]
}

run "cloud_account_id_is_null_uuid" {
  command = plan

  variables {
    cloud_account_id = "00000000-0000-0000-0000-000000000000"
  }

  expect_failures = [
    var.cloud_account_id,
  ]
}

run "storage_class_is_invalid" {
  command = plan

  variables {
    storage_class = "INVALID_CLASS"
  }

  expect_failures = [
    var.cloud_account_id,
    var.storage_class,
  ]
}

run "customer_managed_key_with_empty_name" {
  command = plan

  variables {
    customer_managed_keys = [{
      name      = ""
      ring_name = "test-key-ring"
      region    = "us-central1"
    }]
  }

  expect_failures = [
    var.cloud_account_id,
    var.customer_managed_keys,
  ]
}

run "customer_managed_key_with_empty_ring_name" {
  command = plan

  variables {
    customer_managed_keys = [{
      name      = "test-key"
      ring_name = ""
      region    = "us-central1"
    }]
  }

  expect_failures = [
    var.cloud_account_id,
    var.customer_managed_keys,
  ]
}

run "customer_managed_key_with_empty_region" {
  command = plan

  variables {
    customer_managed_keys = [{
      name      = "test-key"
      ring_name = "test-key-ring"
      region    = ""
    }]
  }

  expect_failures = [
    var.cloud_account_id,
    var.customer_managed_keys,
  ]
}
