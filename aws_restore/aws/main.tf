terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

variable "profile" {
  type        = string
  description = "AWS profile."
}

provider "aws" {
  profile = var.profile
  region  = "us-east-2"
}

# Ubuntu 18.04 LTS server
resource "aws_instance" "compute" {
  ami           = "ami-040ea95249cccbe1c"
  instance_type = "t3.nano"

  root_block_device {
    tags = {
      Name    = "root-vol"
      Version = "v0"
    }
  }

  ebs_block_device {
    device_name = "/dev/sdd"
    volume_size = 5

    tags = {
      Name    = "data-vol"
      Version = "v0"
    }
  }

  tags = {
    Name    = "compute"
    Version = "v0"
  }
}

# To restore from snapshots, simply comment the resource above and uncomment
# the lines below. Note that after the first recovery the lines below can be
# used to stay on the latest snapshot of the instance.

#data "aws_ami" "ami_compute" {
#  owners      = ["self"]
#  most_recent = true
#
#  filter {
#    name   = "tag:Name"
#    values = ["compute"]
#  }
#  filter {
#    name   = "tag:Version"
#    values = ["v0"]
#  }
#}
#
#data "aws_ebs_snapshot" "snap_data_vol" {
#  most_recent = true
#
#  filter {
#    name   = "tag:Name"
#    values = ["data-vol"]
#  }
#  filter {
#    name   = "tag:Version"
#    values = ["v0"]
#  }
#}
#
#resource "aws_instance" "compute" {
#  ami           = data.aws_ami.ami_compute.id
#  instance_type = "t3.nano"
#
#  root_block_device {
#    tags = {
#      Name    = "root-vol"
#      Version = "v1"
#    }
#  }
#
#  ebs_block_device {
#    device_name = "/dev/sdd"
#    snapshot_id = data.aws_ebs_snapshot.snap_data_vol.id
#
#    tags = {
#      Name    = "data-vol"
#      Version = "v1"
#    }
#  }
#
#  tags = {
#    Name    = "compute"
#    Version = "v1"
#  }
#
#  ## The lifecycle meta-argument can be used to create the new infrastructure
#  ## before destroying the old.
#  #lifecycle {
#  #  create_before_destroy = true
#  #}
#}
