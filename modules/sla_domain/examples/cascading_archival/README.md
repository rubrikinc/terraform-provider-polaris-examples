# Cascading Archival Example

This example creates an SLA domain with cross-cluster replication and cascading archival from the replication target.

## Features

- Daily backups with 7-day retention on the source cluster
- Replication to a target cluster with 7-day local retention
- Cascading archival from the target cluster after 7 days
- Azure Archive tiering with 24-hour minimum accessible duration

## Usage

```bash
terraform init
terraform apply \
  -var="source_cluster_name=SOURCE-CLUSTER" \
  -var="target_cluster_name=TARGET-CLUSTER" \
  -var="archival_location_name=My Archival Location"
```

## Prerequisites

- Two Rubrik clusters must be registered in RSC with replication configured
- An archival location must be configured on the target cluster
- All names must be provided via variables

## Architecture

```
Source Cluster → Replication → Target Cluster → Cascading Archival → Cloud Archive
     (7 days)                      (7 days)           (after 7 days)
```

