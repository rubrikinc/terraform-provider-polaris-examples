variable "cloud_type" {
  description = "AWS cloud type. Possible values are: STANDARD, GOV. Defaults to STANDARD."
  type        = string
  default     = null
}

variable "ec2_recovery_role_path" {
  description = "AWS EC2 recovery role path."
  type        = string
  default     = null
}

variable "external_id" {
  description = "AWS trust policy external ID."
  type        = string
}

variable "features" {
  description = "RSC features with permission groups."
  type = map(object({
    permission_groups = set(string)
  }))
}

variable "role_path" {
  description = "AWS role path. Defaults to '/'."
  type        = string
  default     = "/"
}

variable "rsc_user_arn" {
  type        = string
  description = "RSC user ARN."
}

variable "tags" {
  description = "Tags to apply to AWS resources created."
  type        = map(string)
  default     = {}
}
