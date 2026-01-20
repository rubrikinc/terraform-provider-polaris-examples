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

variable "existing_bucket_name" {
  description = "Existing S3 bucket name to use for the cluster"
  type        = string
}

variable "existing_instance_profile_name" {
  description = "Existing IAM instance profile name to use for the cluster"
  type        = string
}

variable "existing_security_group_ids" {
  description = "Existing security group IDs to use for the cluster"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to AWS resources created which supports tags."
  type        = map(string)
  default = {
    example    = "with_existing_resources"
    module     = "aws_cloud_cluster"
    repository = "terraform-provider-polaris-examples"
  }
}

provider "aws" {
  region = var.region
}

# Create an AWS cloud cluster using existing AWS resources
# This example demonstrates how to use pre-existing S3 bucket, IAM roles, and security groups
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

  # Use Existing AWS Resources
  bucket_name           = var.existing_bucket_name
  instance_profile_name = var.existing_instance_profile_name
  security_group_ids    = var.existing_security_group_ids

  # Optional: Advanced Cluster Settings
  num_nodes            = 5
  enable_immutability  = true
  use_placement_groups = true

  # VM Configuration
  cdm_version   = "9.4.0-p2-30507"
  instance_type = "M6I_4XLARGE"
  vm_type       = "EXTRA_DENSE"

  # DNS and NTP Configuration
  dns_name_servers   = ["10.0.0.2", "10.0.0.3"]
  dns_search_domains = ["example.com", "internal.example.com"]
  ntp_servers        = ["time.example.com"]

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

output "iam_instance_profile_name" {
  description = "The name of the IAM instance profile"
  value       = module.aws_cloud_cluster.iam_instance_profile_name
}

