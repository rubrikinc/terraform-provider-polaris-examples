provider "polaris" {}

data "polaris_account" "all" {}

locals {
  # Operations scoped to CLUSTER_ROOT only.
  cluster_op_set = toset([
    "VIEW_CLUSTER",
    "UPGRADE_CLUSTER",
    "REMOVE_CLUSTER",
    "MANAGE_CLUSTER_SETTINGS",
    "MANAGE_SUPPORT_TUNNEL",
    "MANAGE_CLUSTER_DISKS",
    "ADD_CLUSTER_NODES",
    "RECOVER_CLUSTER",
    "REMOVE_CLUSTER_NODES",
    "VIEW_CDM_ADMIN",
    "MANAGE_CDM_ADMIN",
    "VIEW_SMB_DOMAIN",
    "MANAGE_SMB_DOMAIN",
    "ACCESS_CDM_CLUSTER",
    "VIEW_CDM_SYS_CONFIG",
    "EDIT_CDM_SYS_CONFIG",
    "VIEW_CDM_NETWORK_SETTING",
    "EDIT_CDM_NETWORK_SETTING",
    "VIEW_CDM_SUPPORT_SETTING",
    "EDIT_CDM_SUPPORT_SETTING",
  ])
  cluster_operations = [
    for op in data.polaris_account.all.operations : op
    if contains(local.cluster_op_set, op)
  ]

  # Operations scoped to both CLUSTER_ROOT and CROSS_ACCOUNT_CLUSTER_ROOT.
  cluster_cross_account_op_set = toset([
    "USE_AS_REPLICATION_TARGET",
    "VIEW_REPLICATION_SETTINGS",
  ])
  cluster_cross_account_operations = [
    for op in data.polaris_account.all.operations : op
    if contains(local.cluster_cross_account_op_set, op)
  ]

  # --- GlobalResource operation groups ---

  # System and infrastructure.
  system_ops = toset([
    "ADD_CLUSTER",
    "VIEW_SYSTEM_PREFERENCE",
    "EDIT_SYSTEM_PREFERENCE",
    "VIEW_CERTIFICATE",
    "MANAGE_CERTIFICATE",
    "MANAGE_GUEST_OS_CREDENTIAL",
    "VIEW_GUEST_OS_CREDENTIAL",
    "VIEW_STORAGE_SETTINGS",
    "EDIT_REPLICATION_SETTINGS",
    "VIEW_NETWORK_THROTTLE_SETTINGS",
    "MANAGE_ARCHIVAL_NETWORK_THROTTLE_SETTINGS",
    "EDIT_NETWORK_THROTTLE_SETTINGS",
  ])

  # Monitoring and events.
  monitoring_ops = toset([
    "VIEW_NON_SYSTEM_EVENT",
    "VIEW_SYSTEM_EVENT",
    "CANCEL_RUNNING_ACTIVITY",
    "VIEW_AUDIT_LOG",
    "VIEW_IP_ADDRESS_IN_AUDITS",
    "VIEW_WEBHOOKS",
    "MANAGE_WEBHOOKS",
    "VIEW_SYSLOG",
    "MANAGE_SYSLOG",
    "VIEW_SNMP",
    "MANAGE_SNMP",
    "VIEW_SUPPORT_BUNDLE",
    "MANAGE_SUPPORT_BUNDLE",
    "VIEW_DL_EMAIL_SETTINGS",
    "MANAGE_DL_EMAIL_SETTINGS",
  ])

  # Reporting.
  reporting_ops = toset([
    "VIEW_REPORT",
    "MODIFY_REPORT",
    "CREATE_REPORT",
    "DELETE_REPORT",
    "MANAGE_LEGAL_HOLD",
  ])

  # Cloud accounts.
  cloud_account_ops = toset([
    "VIEW_AWS_CLOUD_ACCOUNT",
    "ADD_AWS_CLOUD_ACCOUNT",
    "EDIT_AWS_CLOUD_ACCOUNT",
    "DELETE_AWS_CLOUD_ACCOUNT",
    "VIEW_AZURE_CLOUD_ACCOUNT",
    "ADD_AZURE_CLOUD_ACCOUNT",
    "EDIT_AZURE_CLOUD_ACCOUNT",
    "DELETE_AZURE_CLOUD_ACCOUNT",
    "VIEW_GCP_CLOUD_ACCOUNT",
    "ADD_GCP_CLOUD_ACCOUNT",
    "EDIT_GCP_CLOUD_ACCOUNT",
    "DELETE_GCP_CLOUD_ACCOUNT",
    "VIEW_OCI_CLOUD_ACCOUNT",
    "ADD_OCI_CLOUD_ACCOUNT",
    "EDIT_OCI_CLOUD_ACCOUNT",
    "DELETE_OCI_CLOUD_ACCOUNT",
  ])

  # Users, roles, and access control.
  access_control_ops = toset([
    "VIEW_USER",
    "MANAGE_USER",
    "MANAGE_LOCKOUT",
    "VIEW_SECURITY_POLICY",
    "MANAGE_SECURITY_POLICY",
    "MANAGE_AUTH_DOMAIN",
    "MANAGE_CREDENTIALS",
    "VIEW_ROLE",
    "MANAGE_ROLE",
    "ASSIGN_ROLE",
    "VIEW_SERVICE_ACCOUNT",
    "MANAGE_SERVICE_ACCOUNT",
    "MANAGE_SERVICE_ACCOUNT_CREDENTIALS",
    "MANAGE_PAM_INTEGRATION",
    "VIEW_ORGANIZATION_NETWORKS",
    "MANAGE_ORGANIZATION_NETWORKS",
  ])

  # Integrations.
  integration_ops = toset([
    "VIEW_SERVICENOW_INTEGRATION",
    "MANAGE_SERVICENOW_INTEGRATION",
    "VIEW_OKTA_INTEGRATION",
    "MANAGE_OKTA_INTEGRATION",
    "VIEW_ZSCALER_DLP_INTEGRATION",
    "MANAGE_ZSCALER_DLP_INTEGRATION",
    "VIEW_DSPM_INTEGRATIONS",
    "MANAGE_DSPM_INTEGRATIONS",
    "VIEW_GOOGLE_SECOPS_INTEGRATION",
    "MANAGE_GOOGLE_SECOPS_INTEGRATION",
  ])

  # Recovery and orchestration.
  recovery_ops = toset([
    "VIEW_ORCHESTRATED_RECOVERY_APP",
    "MANAGE_RECOVERY_PLAN",
    "MANAGE_ORCHESTRATED_RECOVERY",
  ])

  # Data security, classification, and compliance.
  data_security_ops = toset([
    "VIEW_DATA_CLASS_GLOBAL",
    "CONFIGURE_DATA_CLASS_GLOBAL",
    "EXPORT_DATA_CLASS_GLOBAL",
    "PREVIEW_DATA_CLASSIFICATION_SAMPLES",
    "VIEW_DATA_ACCESS_GOVERNANCE",
    "VIEW_DATA_DETECTION_AND_RESPONSE_ALERTS",
    "VIEW_DATA_SECURITY_DETAILS",
    "MANAGE_SECURITY_VIOLATIONS",
    "MANAGE_SECURITY_POLICIES",
    "TAKE_REMEDIATION_ACTIONS",
  ])

  # Identity resiliency.
  identity_resiliency_ops = toset([
    "VIEW_IDENTITY_RESILIENCY",
    "MANAGE_IDENTITY_RESILIENCY",
    "REMEDIATE_IDENTITY_RESILIENCY_VIOLATIONS",
  ])

  # Anomaly detection and threat hunting.
  threat_ops = toset([
    "VIEW_ANOMALY_DETECTION_RESULTS",
    "VIEW_ANOMALY_DETECTION_FILE_DETAILS",
    "DOWNLOAD_ANOMALY_FORENSICS",
    "MANAGE_ANOMALY_DETECTION",
    "VIEW_THREAT_HUNT_RESULTS",
    "CREATE_THREAT_HUNT",
  ])

  # Quarantine.
  quarantine_ops = toset([
    "EDIT_QUARANTINE",
    "RECOVER_FROM_QUARANTINE",
    "MANAGE_AUTO_QUARANTINE",
  ])

  # Combined GlobalResource operations.
  global_op_set = setunion(
    local.system_ops,
    local.monitoring_ops,
    local.reporting_ops,
    local.cloud_account_ops,
    local.access_control_ops,
    local.integration_ops,
    local.recovery_ops,
    local.data_security_ops,
    local.identity_resiliency_ops,
    local.threat_ops,
    local.quarantine_ops,
  )
  global_operations = [
    for op in data.polaris_account.all.operations : op
    if contains(local.global_op_set, op)
  ]

  # Operations scoped to AWSNATIVE_ROOT.
  aws_native_op_set = toset([
    "ADD_AWS_ROLE_CHAINING_CLOUD_ACCOUNT",
    "EDIT_AWS_ROLE_CHAINING_CLOUD_ACCOUNT",
    "DELETE_AWS_ROLE_CHAINING_CLOUD_ACCOUNT",
  ])
  aws_native_operations = [
    for op in data.polaris_account.all.operations : op
    if contains(local.aws_native_op_set, op)
  ]

  # Operations scoped to CROSS_ACCOUNT_PAIR_ROOT.
  cross_account_pair_op_set = toset([
    "VIEW_CROSS_ACCOUNT_PAIR",
    "CREATE_CROSS_ACCOUNT_PAIR",
    "MANAGE_CROSS_ACCOUNT_PAIR",
  ])
  cross_account_pair_operations = [
    for op in data.polaris_account.all.operations : op
    if contains(local.cross_account_pair_op_set, op)
  ]

  # Operations scoped to CHATBOT_ROOT.
  chatbot_op_set = toset([
    "VIEW_CHATBOT",
    "CHAT_WITH_CHATBOT",
    "MANAGE_CHATBOT",
  ])
  chatbot_operations = [
    for op in data.polaris_account.all.operations : op
    if contains(local.chatbot_op_set, op)
  ]

  # Operations scoped to O365_ROOT.
  o365_op_set = toset([
    "SELF_SERVICE_RESTORE",
  ])
  o365_operations = [
    for op in data.polaris_account.all.operations : op
    if contains(local.o365_op_set, op)
  ]
}

module "full_mgmt" {
  source = "../.."

  name = "full-mgmt"

  permissions = concat(
    # Cluster operations scoped to CLUSTER_ROOT.
    [for op in local.cluster_operations : {
      operation = op
      hierarchy = [{
        snappable_type = "AllSubHierarchyType"
        object_ids     = ["CLUSTER_ROOT"]
      }]
    }],

    # Replication operations scoped to CLUSTER_ROOT and CROSS_ACCOUNT_CLUSTER_ROOT.
    [for op in local.cluster_cross_account_operations : {
      operation = op
      hierarchy = [{
        snappable_type = "AllSubHierarchyType"
        object_ids     = ["CLUSTER_ROOT", "CROSS_ACCOUNT_CLUSTER_ROOT"]
      }]
    }],

    # Global operations scoped to GlobalResource.
    [for op in local.global_operations : {
      operation = op
      hierarchy = [{
        snappable_type = "AllSubHierarchyType"
        object_ids     = ["GlobalResource"]
      }]
    }],

    # AWS role chaining operations scoped to AWSNATIVE_ROOT.
    [for op in local.aws_native_operations : {
      operation = op
      hierarchy = [{
        snappable_type = "AllSubHierarchyType"
        object_ids     = ["AWSNATIVE_ROOT"]
      }]
    }],

    # Cross account pair operations scoped to CROSS_ACCOUNT_PAIR_ROOT.
    [for op in local.cross_account_pair_operations : {
      operation = op
      hierarchy = [{
        snappable_type = "AllSubHierarchyType"
        object_ids     = ["CROSS_ACCOUNT_PAIR_ROOT"]
      }]
    }],

    # Chatbot operations scoped to CHATBOT_ROOT.
    [for op in local.chatbot_operations : {
      operation = op
      hierarchy = [{
        snappable_type = "AllSubHierarchyType"
        object_ids     = ["CHATBOT_ROOT"]
      }]
    }],

    # O365 self-service restore scoped to O365_ROOT.
    [for op in local.o365_operations : {
      operation = op
      hierarchy = [{
        snappable_type = "AllSubHierarchyType"
        object_ids     = ["O365_ROOT"]
      }]
    }],
  )
}

output "role_id" {
  description = "The ID of the created custom role."
  value       = module.full_mgmt.role_id
}
