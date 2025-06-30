variable "aws_ami_id" {
  type        = string
  description = "AWS AMI ID."
  default     = "ami-040ea95249cccbe1c"
}

variable "aws_instance_type" {
  type        = string
  description = "AWS instance type."
  default     = "t3.nano"
}

variable "aws_volumes" {
  type = set(object({
    device_name = string
    volume_size = number
  }))
  description = "AWS EBS volume ID."
  default = [{
    device_name : "/dev/sdd",
    volume_size : 5
  }]
}

variable "aws_instance_name" {
  type        = string
  description = "EC2 instance name."
}

variable "rsc_snapshot_timestamp" {
  type        = string
  description = "RSC snapshot timestamp."
  default     = null
}

variable "rsc_snapshot_version" {
  type        = number
  description = "RSC snapshot version."
  default     = null
}

# For AWS account module.

variable "features" {
  type = map(object({
    permission_groups = set(string)
  }))
  description = "RSC features with permission groups."
}

variable "name" {
  type        = string
  description = "AWS account name."
}

variable "native_id" {
  type        = string
  description = "AWS account ID."
}

variable "regions" {
  type        = set(string)
  description = "AWS regions."
}
