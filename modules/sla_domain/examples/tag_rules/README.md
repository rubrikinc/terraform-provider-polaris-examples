# SLA Domain with Tag Rules Example

This example demonstrates how to create an RSC SLA domain with automatic tag-based assignment using tag rules.

## What This Example Creates

- An SLA domain with daily backups (30-day retention)
- A tag rule that automatically protects AWS EC2 instances tagged with `environment=production`

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| sla_name | Name of the SLA domain to create | string | "production-ec2-backup" |

## Outputs

| Name | Description |
|------|-------------|
| sla_domain_id | The ID of the created SLA domain |
| tag_rule_ids | Map of tag rule names to their IDs |

## Tag Rule Behavior

When a tag rule is created and assigned to an SLA domain:

1. RSC scans for objects matching the tag criteria
2. Matching objects are automatically assigned to the SLA domain
3. New objects that match the criteria are automatically protected
4. Objects that no longer match are removed from the SLA domain

## Multiple Tag Rules

You can add multiple tag rules to protect different resources:

```terraform
tag_rules = [
  {
    name        = "aws-production-ec2"
    object_type = "AWS_EC2_INSTANCE"
    tag_key     = "environment"
    tag_value   = "production"
  },
  {
    name        = "aws-critical-ec2"
    object_type = "AWS_EC2_INSTANCE"
    tag_key     = "criticality"
    tag_value   = "high"
  }
]
```

