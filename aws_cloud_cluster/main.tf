# Example showing how to onboard an AWS account to RSC with Data Scanning features. 
# The RSC provider will create a CloudFormation stack granting RSC access to the AWS account. 
# See the aws_cnp_account example for how to onboard an AWS account without using a
# CloudFormation stack (Not supported for Data Scanning).

terraform {
  required_providers {
    polaris = {
      source  = "terraform.rubrik.com/rubrikinc/polaris"
      version = ">=1.1.7"
    }
  }
}

variable "regions" {
  type        = set(string)
  description = "AWS regions."
  default     = ["us-west-2"]
}

variable "cloud" {
  type        = string
  default     = "STANDARD"
  description = "AWS cloud type."
}

variable "ec2_recovery_role_path" {
  type        = string
  default     = ""
  description = "EC2 recovery role path."
}

variable "external_id" {
  type        = string
  default     = ""
  description = "External ID. If left empty, RSC will automatically generate an external ID."
}

variable "features" {
  type = map(object({
    permission_groups = set(string)
  }))
  description = "RSC features with permission groups."
  default = {
    SERVERS_AND_APPS = {
      permission_groups = [
        "CLOUD_CLUSTER_ES"
      ]
    }
  }
}

variable "name" {
  type        = string
  description = "AWS account name."
}

variable "native_id" {
  type        = string
  description = "AWS account ID."
}

variable "role_path" {
  type        = string
  default     = "/"
  description = "AWS role path."
}

variable "profile" {
  type        = string
  description = "AWS profile."
  default     = "default"
}

provider "polaris" {}
data "polaris_account" "account" {}

# Wait 30 seconds for the RSC cloud account to be fully provisioned
# without this, you may see an error if onboarding cces too fast
resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
  depends_on      = [polaris_aws_cnp_account_attachments.attachments]
}

# Create an AWS cloud cluster using RSC
resource "polaris_aws_cloud_cluster" "cces" {
  depends_on           = [time_sleep.wait_30_seconds]
  cloud_account_id     = polaris_aws_cnp_account.account.id
  region               = "us-west-2"
  use_placement_groups = true

  cluster_config {
    cluster_name            = "aws-cces"
    admin_email             = "hello@world.com"
    admin_password          = "RubrikGoForward!"
    dns_name_servers        = ["169.254.169.253"]
    dns_search_domains      = ["example.com"]
    ntp_servers             = ["169.254.169.123"]
    num_nodes               = 1
    bucket_name             = "s3-bucket.do.not.delete"
    enable_immutability     = true
    keep_cluster_on_failure = false
  }

  # VM config items should already exist in AWS
  vm_config {
    cdm_version           = "9.4.0-p2-30507"
    instance_type         = "M6I_2XLARGE"
    instance_profile_name = "rubrik-cces-role"
    vpc_id                = "vpc-01234567890123456"
    subnet_id             = "subnet-01234567890123456"
    security_group_ids    = ["sg-01234567890123456", "sg-78901234567890123"]
  }
}

output "account" {
  value = data.polaris_account.account
}
