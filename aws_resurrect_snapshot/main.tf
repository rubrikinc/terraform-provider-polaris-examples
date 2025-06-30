locals {
  rsc_ami_id  = one(polaris_aws_snapshot.snapshot[*].ec2_ami_id)
  rsc_volumes = one(polaris_aws_snapshot.snapshot[*].ec2_volumes)
}

# Onboard the AWS account to RSC. This allows RSC to backup the EC2 instance
# created further down. Note, in this PoC the SLA domain is assigned manually
# in the RSC UI.
module "account" {
  source = "./account"

  features  = var.features
  name      = var.name
  native_id = var.native_id
  regions   = var.regions
}

# Look up the EC2 instance ID. This workaround is needed to break a cyclic
# dependency between the aws_instance and polaris_aws_snapshot resources.
data "aws_instance" "instance" {
  count = var.rsc_snapshot_timestamp != null ? 1 : 0

  filter {
    name   = "tag:Name"
    values = [var.aws_instance_name]
  }

  filter {
    name   = "instance-state-name"
    values = ["pending", "running"]
  }
}

# Resurrect a snapshot if a timestamp or latest is specified. When latest is
# specified, latest will mean the last snapshot available as of now. To reset
# the meaning of latest, i.e. so an even later snapshot is used, increase the
# value of version.
resource "polaris_aws_snapshot" "snapshot" {
  count = var.rsc_snapshot_timestamp != null ? 1 : 0

  ec2_instance_id = data.aws_instance.instance[0].id
  timestamp       = var.rsc_snapshot_timestamp != "latest" ? var.rsc_snapshot_timestamp : null
  version         = var.rsc_snapshot_version
}

# Create the EC2 instance. The root block device comes from the AMI.
resource "aws_instance" "instance" {
  ami           = local.rsc_ami_id != null ? local.rsc_ami_id : var.aws_ami_id
  instance_type = var.aws_instance_type

  # Create the initial block devices.
  dynamic "ebs_block_device" {
    for_each = local.rsc_volumes != null ? [] : var.aws_volumes
    content {
      device_name = ebs_block_device.value["device_name"]
      volume_size = ebs_block_device.value["volume_size"]
    }
  }

  # Create the block devices from the resurrected snapshot.
  dynamic "ebs_block_device" {
    for_each = local.rsc_volumes != null ? local.rsc_volumes : []
    content {
      device_name = ebs_block_device.value["device_name"]
      snapshot_id = ebs_block_device.value["snapshot_id"]
    }
  }

  tags = {
    Name = var.aws_instance_name
  }
}
