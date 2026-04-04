terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.4.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">= 1.1.7"
    }
  }
}

variable "region" {
  description = "AWS region for the cloud cluster"
  type        = string
  default     = "us-west-2"
}

variable "vpc_id" {
  description = "VPC ID where the cluster will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the cluster will be deployed"
  type        = string
}

variable "tags" {
  description = "Tags to apply to AWS resources created which supports tags."
  type        = map(string)
  default = {
    example    = "basic"
    module     = "aws_cloud_cluster"
    repository = "terraform-provider-polaris-examples"
  }
}

provider "aws" {
  region = var.region
}

# Create an AWS cloud cluster with auto-created resources
module "aws_cloud_cluster" {
  source = "../.."

  # Cloud Account Configuration
  cloud_account_name = "my-aws-account"
  region             = var.region

  # Cluster Configuration
  cluster_name   = "my-cloud-cluster"
  admin_email    = "admin@example.com"
  admin_password = "RubrikGoForward!"

  # Network Configuration
  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id

  # Security Group Configuration - using CIDR blocks
  ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
  egress_allowed_cidr_blocks  = ["0.0.0.0/0"]

  # Optional: Cluster Settings
  num_nodes            = 3
  enable_immutability  = true
  use_placement_groups = true

  tags = var.tags
}

output "cloud_cluster_id" {
  description = "The ID of the cloud cluster"
  value       = module.aws_cloud_cluster.cloud_cluster_id
}

output "cloud_cluster_name" {
  description = "The name of the cloud cluster"
  value       = module.aws_cloud_cluster.cloud_cluster_name
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.aws_cloud_cluster.s3_bucket_name
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.aws_cloud_cluster.security_group_id
}

output "iam_instance_profile_name" {
  description = "The name of the IAM instance profile"
  value       = module.aws_cloud_cluster.iam_instance_profile_name
}

