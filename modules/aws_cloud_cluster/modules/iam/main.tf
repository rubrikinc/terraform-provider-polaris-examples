# IAM Module for Rubrik Cloud Cluster

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# IAM Role for Rubrik Cluster EC2 instances
resource "aws_iam_role" "rubrik_cluster" {
  name = "rubrik-cces-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for S3 access
resource "aws_iam_policy" "rubrik_s3_access" {
  name        = "${var.cluster_name}-rubrik-s3-access"
  description = "Policy for Rubrik cluster S3 access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:PutObject*",
          "s3:GetObject*",
          "s3:DeleteObject*",
          "s3:BypassGovernanceRetention",
          "s3:ListMultipartUploadParts"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket*",
          "s3:GetBucket*",
          "s3:PutBucketObjectLockConfiguration"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}"
      }
      ], var.kms_key_arn != null ? [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = var.kms_key_arn
      }
    ] : [])
  })

  tags = var.tags
}

# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "rubrik_s3_access" {
  role       = aws_iam_role.rubrik_cluster.name
  policy_arn = aws_iam_policy.rubrik_s3_access.arn

  depends_on = [
    aws_iam_role.rubrik_cluster,
    aws_iam_policy.rubrik_s3_access
  ]
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "rubrik_cluster" {
  name = "rubrik-cces-${var.cluster_name}-profile"
  role = aws_iam_role.rubrik_cluster.name
  tags = var.tags

  # Ensure the instance profile is created only after all policies are attached
  depends_on = [
    aws_iam_role_policy_attachment.rubrik_s3_access
  ]
}
