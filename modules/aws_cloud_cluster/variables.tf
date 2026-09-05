# Rubrik Polaris Cloud Cluster Variables

variable "cloud_account_name" {
  description = "AWS account name shown in RSC"
  type        = string

  validation {
    condition     = var.cloud_account_name != null && var.cloud_account_name != ""
    error_message = "Cloud account name must be a non-empty string."
  }
}

variable "region" {
  description = "AWS region for the cloud cluster"
  type        = string
  default     = "us-west-2"
}

variable "use_placement_groups" {
  description = "Whether to use placement groups for the cluster, this is recommended to be enabled"
  type        = bool
  default     = true
}

# Cluster Configuration Variables
variable "cluster_name" {
  description = "Name of the cloud cluster"
  type        = string

  validation {
    condition     = var.cluster_name != null && var.cluster_name != ""
    error_message = "Cluster name must be a non-empty string."
  }
}

variable "admin_email" {
  description = "Admin email for the cluster"
  type        = string

  validation {
    condition     = var.admin_email != null && var.admin_email != ""
    error_message = "Admin email must be a non-empty string."
  }
}

variable "admin_password" {
  description = "Admin password for the cluster"
  type        = string
  sensitive   = true

  validation {
    condition     = var.admin_password != null && var.admin_password != ""
    error_message = "Admin password must be a non-empty string."
  }
}

variable "dns_name_servers" {
  description = "DNS name servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "dns_search_domains" {
  description = "DNS search domains"
  type        = list(string)
  default     = ["example.com"]
}

variable "ntp_servers" {
  description = "NTP servers"
  type        = list(string)
  default     = ["pool.ntp.org"]
}

variable "num_nodes" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 3
}

variable "bucket_name" {
  description = "S3 bucket name (optional - will be created if not provided)"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key ARN for S3 bucket encryption (optional - only needed if using SSE-KMS)"
  type        = string
  default     = null
}

variable "enable_immutability" {
  description = "Enable S3 bucket immutability"
  type        = bool
  default     = true
}

variable "keep_cluster_on_failure" {
  description = "Keep cluster on failure"
  type        = bool
  default     = false
}

# VM Configuration Variables
variable "cdm_version" {
  description = "CDM version"
  type        = string
  default     = "9.4.0-p2-30507"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "M6I_2XLARGE"

  validation {
    condition = contains([
      "M5_4XLARGE",
      "M6I_2XLARGE",
      "M6I_4XLARGE",
      "M6I_8XLARGE",
      "R6I_4XLARGE",
      "M6A_2XLARGE",
      "M6A_4XLARGE",
      "M6A_8XLARGE",
      "R6A_4XLARGE",
    ], var.instance_type)
    error_message = "Invalid instance type. Allowed values are: M5_4XLARGE, M6I_2XLARGE, M6I_4XLARGE, M6I_8XLARGE, R6I_4XLARGE, M6A_2XLARGE, M6A_4XLARGE, M6A_8XLARGE, R6A_4XLARGE."
  }
}

variable "vm_type" {
  description = "VM type"
  type        = string
  default     = "EXTRA_DENSE"

  validation {
    condition = contains([
      "STANDARD",
      "DENSE",
      "EXTRA_DENSE",
    ], var.vm_type)
    error_message = "Invalid VM type. Allowed values are: STANDARD, DENSE, EXTRA_DENSE."
  }
}

variable "instance_profile_name" {
  description = "IAM instance profile name (optional - will be created if not provided)"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID where the cluster will be deployed"
  type        = string

  validation {
    condition     = var.vpc_id != null && var.vpc_id != ""
    error_message = "VPC ID must be a non-empty string."
  }
}

variable "subnet_id" {
  description = "Subnet ID where the cluster will be deployed"
  type        = string

  validation {
    condition     = var.subnet_id != null && var.subnet_id != ""
    error_message = "Subnet ID must be a non-empty string."
  }
}

variable "security_group_ids" {
  description = "Security group IDs (optional - will be created if not provided)"
  type        = list(string)
  default     = null
}

# Additional AWS Resource Variables

variable "ingress_allowed_prefix_list_ids" {
  description = "Prefix list IDs allowed for ingress security group access (use either this OR ingress_allowed_cidr_blocks, not both)"
  type        = list(string)
  default     = []

  validation {
    condition     = !(length(var.ingress_allowed_prefix_list_ids) > 0 && length(var.ingress_allowed_cidr_blocks) > 0)
    error_message = "You must specify either ingress_allowed_prefix_list_ids OR ingress_allowed_cidr_blocks, not both."
  }
}

variable "egress_allowed_prefix_list_ids" {
  description = "Prefix list IDs allowed for egress security group access (use either this OR egress_allowed_cidr_blocks, not both)"
  type        = list(string)
  default     = []

  validation {
    condition     = !(length(var.egress_allowed_prefix_list_ids) > 0 && length(var.egress_allowed_cidr_blocks) > 0)
    error_message = "You must specify either egress_allowed_prefix_list_ids OR egress_allowed_cidr_blocks, not both."
  }
}

variable "ingress_allowed_cidr_blocks" {
  description = "CIDR blocks allowed for ingress security group access (use either this OR ingress_allowed_prefix_list_ids, not both)"
  type        = list(string)
  default     = []
}

variable "egress_allowed_cidr_blocks" {
  description = "CIDR blocks allowed for egress security group access (use either this OR egress_allowed_prefix_list_ids, not both)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
