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

variable "aws_eks_cluster_region" {
  description = "EKS cluster region."
  type        = string
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

variable "aws_eks_version" {
  description = "EKS version."
  type        = string
  default     = "1.29"
}

variable "aws_eks_master_node_role_arn" {
  description = "EKS master node role ARN."
  type        = string
}

variable "aws_eks_worker_node_instance_profile" {
  description = "EKS worker node instance profile."
  type        = string
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
