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

variable "vpc_cidr" {
  description = "CIDR for the VPC."
  type        = string
}

variable "tags" {
  description = "Tags to apply to AWS resources created."
  type        = map(string)
  default     = null
}
