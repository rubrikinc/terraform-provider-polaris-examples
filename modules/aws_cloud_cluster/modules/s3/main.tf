# S3 Module for Rubrik Cloud Cluster

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# S3 Bucket for Rubrik
resource "aws_s3_bucket" "rubrik_storage" {
  bucket = var.bucket_name

  tags = var.tags
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "rubrik_storage" {
  bucket = aws_s3_bucket.rubrik_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "rubrik_storage" {
  bucket = aws_s3_bucket.rubrik_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
