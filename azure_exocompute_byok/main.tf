data "azuread_domains" "aad_domains" {
  only_initial = true
}

# Create an Azure AD application and service principal with a secret.
resource "azuread_application" "application" {
  display_name     = "RSC application - ${data.polaris_account.account.name}"
  sign_in_audience = "AzureADMultipleOrgs"
  web {
    homepage_url = "https://${data.polaris_account.account.fqdn}/setup_azure"
  }
}

resource "azuread_application_password" "application_secret" {
  application_id = azuread_application.application.id
}

# The application secret is needed to pull RSC images from the RSC ACR registry.
output "application_secret" {
  value     = azuread_application_password.application_secret.value
  sensitive = true
}

resource "azuread_service_principal" "service_principal" {
  client_id = azuread_application.application.client_id
}

resource "azuread_service_principal_password" "service_principal_secret" {
  service_principal_id = azuread_service_principal.service_principal.id
}

data "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  resource_group_name = var.cluster_resource_group
}

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

data "azurerm_subscription" "subscription" {}

data "polaris_account" "account" {}

data "polaris_azure_permissions" "features" {
  for_each          = var.features
  feature           = each.key
  permission_groups = each.value.permission_groups
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  location            = data.azurerm_resource_group.resource_group.location
  name                = var.managed_identity_name
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

# Create and assign the subscription level role definition.
resource "azurerm_role_definition" "subscription" {
  for_each = data.polaris_azure_permissions.features
  name     = "Terraform - Azure Permissions Example Subscription Level - ${each.value.feature}"
  scope    = data.azurerm_subscription.subscription.id

  dynamic "permissions" {
    for_each = length(concat(each.value.subscription_actions, each.value.subscription_data_actions, each.value.subscription_not_actions, each.value.subscription_not_data_actions)) > 0 ? [1] : []
    content {
      actions          = each.value.subscription_actions
      data_actions     = each.value.subscription_data_actions
      not_actions      = each.value.subscription_not_actions
      not_data_actions = each.value.subscription_not_data_actions
    }
  }
}

resource "azurerm_role_assignment" "subscription" {
  for_each           = data.polaris_azure_permissions.features
  principal_id       = azuread_service_principal.service_principal.object_id
  role_definition_id = azurerm_role_definition.subscription[each.key].role_definition_resource_id
  scope              = data.azurerm_subscription.subscription.id
}

# Create and assign the resource group level role definition.
resource "azurerm_role_definition" "resource_group" {
  for_each = data.polaris_azure_permissions.features
  name     = "Terraform - Azure Permissions Example Resource Group Level - ${each.value.feature}"
  scope    = data.azurerm_resource_group.resource_group.id

  dynamic "permissions" {
    for_each = length(concat(each.value.resource_group_actions, each.value.resource_group_data_actions, each.value.resource_group_not_actions, each.value.resource_group_not_data_actions)) > 0 ? [1] : []
    content {
      actions          = each.value.resource_group_actions
      data_actions     = each.value.resource_group_data_actions
      not_actions      = each.value.resource_group_not_actions
      not_data_actions = each.value.resource_group_not_data_actions
    }
  }
}

resource "azurerm_role_assignment" "resource_group" {
  for_each           = data.polaris_azure_permissions.features
  principal_id       = azuread_service_principal.service_principal.object_id
  role_definition_id = azurerm_role_definition.resource_group[each.key].role_definition_resource_id
  scope              = data.azurerm_resource_group.resource_group.id
}

# Onboard the service principal to RSC.
resource "polaris_azure_service_principal" "service_principal" {
  app_id        = azuread_application.application.client_id
  app_name      = azuread_application.application.display_name
  app_secret    = azuread_service_principal_password.service_principal_secret.value
  tenant_domain = data.azuread_domains.aad_domains.domains.0.domain_name
  tenant_id     = azuread_service_principal.service_principal.application_tenant_id
}

# Onboard the subscription to RSC.
resource "polaris_azure_subscription" "subscription" {
  subscription_id   = data.azurerm_subscription.subscription.subscription_id
  subscription_name = data.azurerm_subscription.subscription.display_name
  tenant_domain     = polaris_azure_service_principal.service_principal.tenant_domain

  dynamic "cloud_native_protection" {
    for_each = contains(keys(var.features), "CLOUD_NATIVE_PROTECTION") ? [1] : []
    content {
      permission_groups     = data.polaris_azure_permissions.features["CLOUD_NATIVE_PROTECTION"].permission_groups
      permissions           = data.polaris_azure_permissions.features["CLOUD_NATIVE_PROTECTION"].id
      resource_group_name   = var.resource_group_name
      resource_group_region = var.region
      regions               = [var.region]
    }
  }

  dynamic "cloud_native_archival" {
    for_each = contains(keys(var.features), "CLOUD_NATIVE_ARCHIVAL") ? [1] : []
    content {
      permission_groups     = data.polaris_azure_permissions.features["CLOUD_NATIVE_ARCHIVAL"].permission_groups
      permissions           = data.polaris_azure_permissions.features["CLOUD_NATIVE_ARCHIVAL"].id
      resource_group_name   = var.resource_group_name
      resource_group_region = var.region
      regions               = [var.region]
    }
  }

  dynamic "cloud_native_archival_encryption" {
    for_each = contains(keys(var.features), "CLOUD_NATIVE_ARCHIVAL_ENCRYPTION") ? [1] : []
    content {
      permission_groups                                  = data.polaris_azure_permissions.features["CLOUD_NATIVE_ARCHIVAL_ENCRYPTION"].permission_groups
      permissions                                        = data.polaris_azure_permissions.features["CLOUD_NATIVE_ARCHIVAL_ENCRYPTION"].id
      resource_group_name                                = var.resource_group_name
      resource_group_region                              = var.region
      regions                                            = [var.region]
      user_assigned_managed_identity_name                = azurerm_user_assigned_identity.managed_identity.name
      user_assigned_managed_identity_principal_id        = azurerm_user_assigned_identity.managed_identity.principal_id
      user_assigned_managed_identity_region              = azurerm_user_assigned_identity.managed_identity.location
      user_assigned_managed_identity_resource_group_name = azurerm_user_assigned_identity.managed_identity.resource_group_name
    }
  }

  dynamic "exocompute" {
    for_each = contains(keys(var.features), "EXOCOMPUTE") ? [1] : []
    content {
      permission_groups     = data.polaris_azure_permissions.features["EXOCOMPUTE"].permission_groups
      permissions           = data.polaris_azure_permissions.features["EXOCOMPUTE"].id
      resource_group_name   = var.resource_group_name
      resource_group_region = var.region
      regions               = [var.region]
    }
  }

  dynamic "sql_db_protection" {
    for_each = contains(keys(var.features), "AZURE_SQL_DB_PROTECTION") ? [1] : []
    content {
      permission_groups = data.polaris_azure_permissions.features["AZURE_SQL_DB_PROTECTION"].permission_groups
      permissions       = data.polaris_azure_permissions.features["AZURE_SQL_DB_PROTECTION"].id
      regions           = [var.region]
    }
  }

  dynamic "sql_mi_protection" {
    for_each = contains(keys(var.features), "AZURE_SQL_MI_PROTECTION") ? [1] : []
    content {
      permission_groups = data.polaris_azure_permissions.features["AZURE_SQL_MI_PROTECTION"].permission_groups
      permissions       = data.polaris_azure_permissions.features["AZURE_SQL_MI_PROTECTION"].id
      regions           = [var.region]
    }
  }

  # This resource must explicitly depend on the role definition and the role
  # assignment so that the role is updated before RSC is notified.
  depends_on = [
    azurerm_role_definition.subscription,
    azurerm_role_definition.resource_group,
  ]
}

resource "polaris_azure_private_container_registry" "registry" {
  cloud_account_id = polaris_azure_subscription.subscription.id
  app_id           = azuread_application.application.client_id
  url              = var.registry_url
}

resource "polaris_azure_exocompute" "exocompute" {
  cloud_account_id = polaris_azure_subscription.subscription.id
  region           = var.region
}

resource "polaris_azure_exocompute_cluster_attachment" "cluster" {
  exocompute_id = polaris_azure_exocompute.exocompute.id
  cluster_name  = "${var.cluster_resource_group}/${var.cluster_name}"

  # The PCR must be created before the cluster attachment, otherwise the
  # manifest will contain references to the wrong CR.
  depends_on = [
    polaris_azure_private_container_registry.registry,
  ]
}

# Select one of the two modules below to deploy the K8s resources from the RSC
# K8s manifest to the AKS cluster.

# module "manifest" {
#   source = "./manifest1"
#
#   aks_cluster_name           = var.cluster_name
#   aks_cluster_resource_group = var.cluster_resource_group
#   manifest                   = polaris_azure_exocompute_cluster_attachment.cluster.manifest
# }

# module "manifest" {
#   source = "./manifest2"
#
#   aks_host                   = data.azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
#   aks_cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks_cluster.kube_config.0.cluster_ca_certificate)
#   aks_client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_certificate)
#   aks_client_key             = base64decode(data.azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_key)
#   manifest                   = polaris_azure_exocompute_cluster_attachment.cluster.manifest
# }
