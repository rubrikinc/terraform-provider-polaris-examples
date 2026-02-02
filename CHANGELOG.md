# Changelog

## v1.0.0
* Add `gcp_project` Terraform module.
* Add `gcp_archival_location` Terraform module.
* Add `sla_domain` Terraform module.
* Rename `aws_cnp_account` to `aws_iam_account` and move it to the `modules/` directory.
* Update the `aws_exocompute` tests to use the `aws_iam_account` module.
* Add support for the `KUBERNETES_PROTECTION` feature to the `aws_iam_account` module.
