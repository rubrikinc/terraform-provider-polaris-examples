#!/usr/bin/env bash
terraform-docs markdown table --hide-empty --output-file README.md --sort ./aws_cloud_cluster
terraform-docs markdown table --hide-empty --output-file README.md --sort ./aws_cnp_account
terraform-docs markdown table --hide-empty --output-file README.md --sort ./aws_exocompute
