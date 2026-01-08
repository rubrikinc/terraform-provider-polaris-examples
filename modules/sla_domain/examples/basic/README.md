# Basic SLA Domain Example

This example demonstrates how to create a basic RSC SLA domain with a daily backup schedule.

## Usage

1. Configure the Polaris provider with your credentials
2. Run `terraform init` to initialize the module
3. Run `terraform plan` to preview the changes
4. Run `terraform apply` to create the SLA domain

## What This Example Creates

- An RSC SLA domain named "daily-backup-example"
- Daily backup schedule with 1-day frequency
- 7-day retention for snapshots
- Configured for AWS EC2 EBS workloads

