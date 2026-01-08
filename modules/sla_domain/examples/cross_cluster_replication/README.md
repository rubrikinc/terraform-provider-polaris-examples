# Cross-Cluster Replication Example

This example creates an SLA domain with daily backups and cross-cluster replication between two Rubrik clusters.

## Features

- Daily backups with 7-day retention on the source cluster
- Replication to a target cluster with 7-day retention
- Local retention on the target cluster for 7 days

## Usage

```bash
terraform init
terraform apply \
  -var="source_cluster_name=SOURCE-CLUSTER" \
  -var="target_cluster_name=TARGET-CLUSTER"
```

## Prerequisites

- Two Rubrik clusters must be registered in RSC
- Cluster names must be provided via variables

