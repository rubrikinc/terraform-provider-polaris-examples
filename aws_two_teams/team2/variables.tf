variable "account_id" {
  description = "AWS account ID."
  type        = string
}

variable "account_name" {
  description = "AWS account name."
  type        = string
}

variable "cloud_type" {
  description = "AWS cloud type. Possible values are: STANDARD, GOV. Defaults to STANDARD."
  type        = string
  default     = null
}

variable "external_id" {
  description = "AWS external ID."
  type        = string
}

variable "features" {
  description = "RSC features with permission groups."
  type = map(object({
    permission_groups = set(string)
  }))
}

variable "regions" {
  description = "AWS regions to onboard."
  type        = set(string)
}

variable "instance_profiles" {
  description = "ARNs of the instance profiles to attach to the RSC cloud account."
  type        = map(string)
}

variable "roles" {
  description = "ARNs of the roles to attach to the RSC cloud account."
  type        = map(string)
}
