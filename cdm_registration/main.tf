# Example showing how to register a CDM cluster with RSC.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=1.1.0-beta.1"
    }
  }
}

variable "admin_password" {
  description = "Password for the cluster admin account."
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Cluster name."
  type        = string
}

variable "cluster_node_ip_address" {
  description = "Cluster node IP address."
  type        = string
}

provider "polaris" {}

resource "polaris_cdm_registration" "cdm_registration" {
  admin_password          = var.admin_password
  cluster_name            = var.cluster_name
  cluster_node_ip_address = var.cluster_node_ip_address
}
