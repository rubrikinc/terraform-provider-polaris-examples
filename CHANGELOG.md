# Changelog

## v1.1.0
* Add `gcp_project` Terraform module.
* Add `gcp_archival_location` Terraform module.
* Add `sla_domain` Terraform module.
* Rename `aws_cnp_account` to `aws_iam_account` and move it to the `modules/` directory.
* Update the `aws_exocompute` tests to use the `aws_iam_account` module.
* Add support for the `KUBERNETES_PROTECTION` feature to the `aws_iam_account` module.
* Add `gcp_exocompute` Terraform  module.
* Add support for shared Exocompute to the `aws_iam_account` module.
* Update the `polaris_aws_account` example with `outpost`, `cyber_recovery_data_scanning`, `data_scanning`, and `dspm`
  features.
* Add support for the `CLOUD_DISCOVERY` feature to the `aws_iam_account` module.
