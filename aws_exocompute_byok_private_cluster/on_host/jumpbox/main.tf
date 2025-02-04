terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical.
  owners = ["099720109477"]
}

resource "aws_key_pair" "jumpbox" {
  key_name   = "jumpbox"
  public_key = var.jumpbox_public_key
}

resource "aws_s3_bucket" "jumpbox_data" {
  bucket        = "${var.aws_name_prefix}-jumpbox-data"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "jumpbox_data" {
  bucket = aws_s3_bucket.jumpbox_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "manifest" {
  bucket       = aws_s3_bucket.jumpbox_data.id
  key          = "manifest"
  content      = var.rsc_manifest
  content_type = "text/yaml"

  depends_on = [
    aws_s3_bucket_versioning.jumpbox_data,
  ]
}

resource "aws_instance" "jumpbox" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.jumpbox_instance_type
  key_name      = aws_key_pair.jumpbox.key_name
  subnet_id     = var.public_subnet_id

  user_data_base64 = base64encode(templatefile("${path.module}/user_data.tftpl", {
    on_jumpbox_zip = data.local_file.on_jumpbox_zip.content_base64
  }))
  user_data_replace_on_change = true

  vpc_security_group_ids = [
    var.jumpbox_security_group_id
  ]

  tags = {
    Name = "${var.aws_name_prefix}-jumpbox"
  }
}
