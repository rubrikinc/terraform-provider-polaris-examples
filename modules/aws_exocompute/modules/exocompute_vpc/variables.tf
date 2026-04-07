variable "name" {
  description = "Name for the VPC."
  type        = string
}

variable "public_cidr" {
  description = "CIDR for the public subnet."
  type        = string

  validation {
    condition     = can(cidrhost(var.public_cidr, 0))
    error_message = "Public subnet CIDR must be a valid CIDR block."
  }
}

variable "subnet1_cidr" {
  description = "CIDR for subnet 1."
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet1_cidr, 0))
    error_message = "Subnet 1 CIDR must be a valid CIDR block."
  }
}

variable "subnet2_cidr" {
  description = "CIDR for subnet 2."
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet2_cidr, 0))
    error_message = "Subnet 2 CIDR must be a valid CIDR block."
  }
}

variable "pod_subnet1_cidr" {
  description = "CIDR for pod subnet 1."
  type        = string
  default     = null

  validation {
    condition     = var.pod_subnet1_cidr == null || can(cidrhost(var.pod_subnet1_cidr, 0))
    error_message = "Pod subnet 1 CIDR must be a valid CIDR block."
  }
}

variable "pod_subnet2_cidr" {
  description = "CIDR for pod subnet 2."
  type        = string
  default     = null

  validation {
    condition     = var.pod_subnet2_cidr == null || can(cidrhost(var.pod_subnet2_cidr, 0))
    error_message = "Pod subnet 2 CIDR must be a valid CIDR block."
  }
  validation {
    condition     = (var.pod_subnet1_cidr == null) == (var.pod_subnet2_cidr == null)
    error_message = "Pod subnet1 CIDR and pod subnet2 CIDR must be specified together."
  }
}

variable "vpc_cidr" {
  description = "CIDR for the VPC."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

variable "tags" {
  description = "Tags to apply to AWS resources created."
  type        = map(string)
  default     = null
}
