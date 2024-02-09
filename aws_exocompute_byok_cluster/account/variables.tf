variable "aws_account_id" {
  type        = string
  description = "AWS account ID to protect with Rubrik Security Cloud."
}

variable "aws_account_name" {
  type        = string
  description = "AWS account name to protect with Rubrik Security Cloud."
}

variable "aws_ec2_recovery_role_path" {
  type        = string
  default     = ""
  description = "EC2 recovery role path for the cross account role."
}

variable "aws_external_id" {
  type        = string
  default     = ""
  description = "External ID for the AWS cross account role. If left empty, RSC will automatically generate an external ID."
}

variable "aws_regions_to_protect" {
  type        = set(string)
  description = "AWS regions to protect with Rubrik Security Cloud."
}

variable "aws_role_path" {
  type        = string
  default     = "/"
  description = "AWS role path for cross account role."
}

variable "rsc_cloud_type" {
  type        = string
  default     = "STANDARD"
  description = "AWS cloud type in RSC."
}

variable "rsc_delete_aws_snapshots_on_destroy" {
  type        = bool
  default     = false
  description = "Delete snapshots in AWS when account is removed from Rubrik Security Cloud."
}

variable "rsc_features" {
  type = set(object({
    name              = string
    permission_groups = set(string)
  }))
  description = "RSC features with permission groups."
}
