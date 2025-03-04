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

variable "aws_eks_autoscaling_max_size" {
  type        = number
  default     = 64
  description = "The maximum number of concurrent workers."
}

# If private endpoint access is enabled, then K8s API access from worker nodes
# stays within the customer's VPC. Note that this doesn't disable public access,
# cluster remains accessible from public internet as well. For more information,
# see https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html.
variable "aws_eks_enable_private_endpoint_access" {
  type        = bool
  default     = false
  description = "Enable EKS private endpoint access."
}

variable "aws_eks_kubernetes_version" {
  type        = string
  default     = "1.29"
  description = "Kubernetes version."
}

# If restrict public endpoint access is enabled, then the public access to the
# K8s API server endpoint is restricted to the RSC deployment IPs and the
# Bastion IP, otherwise the endpoint remains accessible to the public internet.
# When enabled, we enable the private endpoint access, otherwise there will be
# no way for workers to communicate with the API server.
variable "aws_eks_restrict_public_endpoint_access" {
  type        = bool
  default     = false
  description = "Restrict EKS public endpoint access."
}

variable "aws_eks_worker_node_instance_type" {
  type        = string
  default     = "m5.xlarge"
  description = "AWS EKS worker node instance type."
}

variable "aws_exocompute_public_subnet_cidr" {
  type        = string
  description = "Public subnet CIDR for the AWS account hosting Exocompute."
}

variable "aws_exocompute_subnet_1_cidr" {
  type        = string
  description = "Subnet 1 CIDR for the AWS account hosting Exocompute."
}

variable "aws_exocompute_subnet_2_cidr" {
  type        = string
  description = "Subnet 2 CIDR for the AWS account hosting Exocompute."
}

variable "aws_exocompute_vpc_cidr" {
  type        = string
  description = "VPC CIDR for the AWS account hosting Exocompute."
}

variable "aws_name_prefix" {
  type        = string
  default     = "rubrik-byok8s"
  description = "Name prefix for all resources created in AWS."
}

# The IP addresses provided will automatically be turned into CIDR addresses.
variable "rsc_deployment_ips" {
  type        = list(string)
  default     = []
  description = "Rubrik Security Cloud deployment IPs. Leaving this blank will use the default IPs."
}

variable "rsc_private_registry_url" {
  type        = string
  description = "URL to customer provided private container registry."
}

variable "manifest_module" {
  type        = string
  default     = "none"
  description = "Module to deploy the RSC Kubernetes manifest with. Valid values are none, manifest1 and manifest2."
}
