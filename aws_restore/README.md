# Restore AWS VM from RSC snapshot
This folder contains an example of how to restore an AWS VM along with any
additional block devices from snapshots taken by RSC. The idea is to tag the VM
and any additional block devices with a `version` tag. When restoring, the VM
and any additional block devices are recreated using the
[Hashicorp AWS Terraform provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
from the most recent snapshots having the specified `version` tag.
