variable "name" {
  description = "Name for the VPC."
  type        = string
}

variable "public_cidr" {
  description = "CIDR for the public subnet."
  type        = string
}

variable "subnet1_cidr" {
  description = "CIDR for subnet 1."
  type        = string
}

variable "subnet2_cidr" {
  description = "CIDR for subnet 2."
  type        = string
}

variable "pod_subnet1_cidr" {
  description = "CIDR for pod subnet 1."
  type        = string
  default     = null
}

variable "pod_subnet2_cidr" {
  description = "CIDR for pod subnet 2."
  type        = string
  default     = null

  validation {
    condition     = (var.pod_subnet1_cidr == null) == (var.pod_subnet2_cidr == null)
    error_message = "Pod subnet1 CIDR and pod subnet2 CIDR must be specified together."
  }
}

variable "vpc_cidr" {
  description = "CIDR for the VPC."
  type        = string
}

variable "tags" {
  description = "Tags to apply to AWS resources created."
  type        = map(string)
  default     = null
}
