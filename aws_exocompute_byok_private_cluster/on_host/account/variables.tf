variable "aws_account_id" {
  description = "AWS account ID to protect with Rubrik Security Cloud."
  type        = string
}

variable "aws_account_name" {
  description = "AWS account name to protect with Rubrik Security Cloud."
  type        = string
}

variable "aws_ec2_recovery_role_path" {
  description = "EC2 recovery role path for the cross account role."
  type        = string
  default     = ""
}

variable "aws_external_id" {
  description = "External ID for the AWS cross account role. If left empty, RSC will automatically generate an external ID."
  type        = string
  default     = ""
}

variable "aws_regions_to_protect" {
  description = "AWS regions to protect with Rubrik Security Cloud."
  type        = set(string)
}

variable "aws_role_path" {
  description = "AWS role path for cross account role."
  type        = string
  default     = "/"
}

variable "rsc_cloud_type" {
  description = "AWS cloud type in RSC."
  type        = string
  default     = "STANDARD"
}

variable "rsc_delete_aws_snapshots_on_destroy" {
  description = "Delete snapshots in AWS when account is removed from Rubrik Security Cloud."
  type        = bool
  default     = false
}

variable "rsc_features" {
  description = "RSC features with permission groups."
  type = set(object({
    name              = string
    permission_groups = set(string)
  }))
}
