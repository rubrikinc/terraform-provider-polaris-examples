variable "aws_access_key" {
  description = "AWS access key."
  sensitive   = true
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret access key."
  sensitive   = true
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

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

variable "aws_eks_access_cidrs" {
  description = "EKS access CIDR blocks."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "aws_eks_autoscaling_max_size" {
  description = "The maximum number of concurrent EKS workers."
  type        = number
  default     = 64
}

# If private endpoint access is enabled, then K8s API access from worker nodes
# stays within the customer's VPC. Note that this doesn't disable public access,
# cluster remains accessible from public internet as well. For more information,
# see https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html.
variable "aws_eks_enable_private_endpoint_access" {
  description = "Enable EKS private endpoint access."
  type        = bool
  default     = false
}

# Enables public access to the K8s API server endpoint. The specific IPs
# having access can be restricted using the aws_eks_access_cidrs variable.
# Note disabling public access will enable private access.
variable "aws_eks_enable_public_endpoint_access" {
  description = "Enable EKS public endpoint access."
  type        = bool
  default     = true
}

variable "aws_eks_kubernetes_version" {
  description = "EKS version."
  type        = string
  default     = "1.29"
}

variable "aws_eks_worker_node_instance_type" {
  description = "EKS worker node instance type."
  type        = string
  default     = "m5.xlarge"
}

variable "aws_exocompute_public_subnet_cidr" {
  description = "Public subnet CIDR block."
  type        = string
}

variable "aws_exocompute_subnet_1_cidr" {
  description = "Subnet 1 CIDR block."
  type        = string
}

variable "aws_exocompute_subnet_2_cidr" {
  description = "Subnet 2 CIDR block."
  type        = string
}

variable "aws_exocompute_vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "aws_name_prefix" {
  description = "Name prefix for all EKS related resources created in AWS."
  type        = string
  default     = "rubrik-byok8s"
}

variable "jumpbox_public_key" {
  description = "Jumpbox public SSH key."
  type        = string
}

variable "rsc_private_registry_url" {
  description = "URL to the customer provided private container registry."
  type        = string
}
