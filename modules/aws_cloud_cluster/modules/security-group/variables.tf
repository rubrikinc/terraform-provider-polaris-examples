# Variables for Security Group Module

variable "cluster_name" {
  description = "Name of the cluster for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "ingress_allowed_prefix_list_ids" {
  description = "Prefix list IDs allowed for ingress traffic (use either this OR ingress_allowed_cidr_blocks, not both)"
  type        = list(string)
  default     = []

  validation {
    condition     = !(length(var.ingress_allowed_prefix_list_ids) > 0 && length(var.ingress_allowed_cidr_blocks) > 0)
    error_message = "You must specify either ingress_allowed_prefix_list_ids OR ingress_allowed_cidr_blocks, not both."
  }
}

variable "egress_allowed_prefix_list_ids" {
  description = "Prefix list IDs allowed for egress traffic (use either this OR egress_allowed_cidr_blocks, not both)"
  type        = list(string)
  default     = []

  validation {
    condition     = !(length(var.egress_allowed_prefix_list_ids) > 0 && length(var.egress_allowed_cidr_blocks) > 0)
    error_message = "You must specify either egress_allowed_prefix_list_ids OR egress_allowed_cidr_blocks, not both."
  }
}

variable "ingress_allowed_cidr_blocks" {
  description = "CIDR blocks allowed for ingress traffic (use either this OR ingress_allowed_prefix_list_ids, not both)"
  type        = list(string)
  default     = []
}

variable "egress_allowed_cidr_blocks" {
  description = "CIDR blocks allowed for egress traffic (use either this OR egress_allowed_prefix_list_ids, not both)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to security group resources"
  type        = map(string)
  default     = {}
}
