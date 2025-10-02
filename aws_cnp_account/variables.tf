variable "cloud" {
  description = "AWS cloud type."
  type        = string
  default     = "STANDARD"
}

variable "ec2_recovery_role_path" {
  description = "EC2 recovery role path."
  type        = string
  default     = ""
}

variable "external_id" {
  description = "External ID. If left empty, RSC will automatically generate an external ID."
  type        = string
  default     = ""
}

variable "features" {
  description = "RSC features with permission groups."
  type = map(object({
    permission_groups = set(string)
  }))
}

variable "name" {
  description = "AWS account name."
  type        = string
}

variable "native_id" {
  description = "AWS account ID."
  type        = string
}

variable "role_path" {
  description = "AWS role path."
  type        = string
  default     = "/"
}

variable "role_type" {
  description = "How the AWS policies should be attached to the IAM roles created for RSC. Possible values: `managed`, `inline` and `legacy`. `legacy` should only be used for backwards compatibility with previously onboarded AWS accounts."
  type        = string
  default     = "managed"

  validation {
    condition     = can(regex("legacy|inline|managed", lower(var.role_type)))
    error_message = "Invalid AWS IAM role type. Possible values: `managed`, `inline` and `legacy`."
  }
}

variable "regions" {
  description = "AWS regions."
  type        = set(string)
}

variable "tags" {
  description = "Tags to apply to AWS resources created."
  type        = map(string)
  default = {
    Environment = "test"
    Example     = "aws_cnp_account"
    Module      = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}
