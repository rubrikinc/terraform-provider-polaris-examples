terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.3.0"
    }
  }
}

# Onboard the Azure account to RSC.
module "azure_subscription" {
  source = "../azure"

  features = {
    SERVERS_AND_APPS : {
      permission_groups = [
        "CLOUD_CLUSTER_ES",
      ],
    }
  }

}

# Create an Azure cloud cluster RSC
resource "polaris_azure_cloud_cluster" "cces" {
  cloud_account_id = module.azure_subscription.cloud_account_id

  cluster_config {
    cluster_name            = var.cluster_name
    admin_email             = var.admin_email
    admin_password          = var.admin_password
    dns_name_servers        = var.dns_name_servers
    ntp_servers             = var.ntp_servers
    num_nodes               = var.num_nodes
    keep_cluster_on_failure = var.keep_cluster_on_failure
  }

  # VM config items should already exist in Azure
  vm_config {
    cdm_version                         = var.cdm_version
    instance_type                       = var.instance_type
    region                              = var.region
    resource_group_name                 = var.resource_group_name
    network_resource_group              = var.network_resource_group
    vnet_resource_group                 = var.vnet_resource_group
    subnet                              = var.subnet
    vnet                                = var.vnet
    network_security_group              = var.network_security_group
    network_security_resource_group     = var.network_security_resource_group
    vm_type                             = var.vm_type
    user_assigned_managed_identity_name = var.user_assigned_managed_identity_name
    storage_account_name                = var.storage_account_name
    container_name                      = var.container_name
    enable_immutability                 = var.enable_immutability
  }
}
