# Archival Example

This example creates an SLA domain with daily backups and archival to AWS S3 with Glacier tiering.

## Features

- Daily backups with 30-day retention
- Archival to S3 after 7 days
- Instant tiering to Glacier for cost optimization

## Usage

```bash
terraform init
terraform apply -var="archival_location_name=my-s3-archival-location"
```

## Prerequisites

- An AWS archival location must already exist in RSC
- The archival location name must be provided via the `archival_location_name` variable

