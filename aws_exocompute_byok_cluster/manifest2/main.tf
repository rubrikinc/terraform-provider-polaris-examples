terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
  }
}

locals {
  # Filter the provided manifest, removing all fluent-bit manifests.
  manifests = [
    for v in [
      for v in split("---", var.manifest) : yamldecode(v)
    ] : v if !contains(local.fluent_bit_names, v.metadata.name)
  ]

  known_resources = [
    "Namespace",
    "ServiceAccount",
    "ClusterRole",
    "Role",
    "ClusterRoleBinding",
    "RoleBinding",
    "ConfigMap",
    "Service",
    "DaemonSet",
    "Deployment",
  ]
}

resource "kubernetes_manifest" "namespace" {
  for_each = {
    for v in local.manifests : lower(v.metadata.name) => v if v.kind == "Namespace"
  }

  manifest = each.value
}

resource "kubernetes_manifest" "service_account" {
  for_each = {
    for v in local.manifests : trim(lower("${try(v.metadata.namespace, "")}-${v.metadata.name}"), "-") => v if v.kind == "ServiceAccount"
  }

  manifest = each.value

  depends_on = [
    kubernetes_manifest.daemonset_fluent_bit,
    kubernetes_manifest.namespace,
  ]
}

resource "kubernetes_manifest" "role" {
  for_each = {
    for v in local.manifests : trim(lower("${try(v.metadata.namespace, "")}-${v.metadata.name}"), "-") => v if v.kind == "ClusterRole" || v.kind == "Role"
  }

  manifest = each.value

  depends_on = [
    kubernetes_manifest.daemonset_fluent_bit,
    kubernetes_manifest.namespace,
  ]
}

resource "kubernetes_manifest" "role_binding" {
  for_each = {
    for v in local.manifests : trim(lower("${try(v.metadata.namespace, "")}-${v.metadata.name}"), "-") => v if v.kind == "ClusterRoleBinding" || v.kind == "RoleBinding"
  }

  manifest = each.value

  depends_on = [
    kubernetes_manifest.service_account,
    kubernetes_manifest.role,
  ]
}

resource "kubernetes_manifest" "config_map" {
  for_each = {
    for v in local.manifests : trim(lower("${try(v.metadata.namespace, "")}-${v.metadata.name}"), "-") => v if v.kind == "ConfigMap"
  }

  manifest = each.value

  depends_on = [
    kubernetes_manifest.daemonset_fluent_bit,
    kubernetes_manifest.namespace,
  ]
}

resource "kubernetes_manifest" "service" {
  for_each = {
    for v in local.manifests : trim(lower("${try(v.metadata.namespace, "")}-${v.metadata.name}"), "-") => v if v.kind == "Service"
  }

  manifest = each.value

  depends_on = [
    kubernetes_manifest.daemonset_fluent_bit,
    kubernetes_manifest.namespace,
  ]
}

resource "kubernetes_manifest" "daemon_set" {
  for_each = {
    for v in local.manifests : trim(lower("${try(v.metadata.namespace, "")}-${v.metadata.name}"), "-") => v if v.kind == "DaemonSet"
  }

  manifest = each.value

  depends_on = [
    kubernetes_manifest.config_map,
    kubernetes_manifest.role_binding,
    kubernetes_manifest.service_account,
  ]
}

resource "kubernetes_manifest" "deployment" {
  for_each = {
    for v in local.manifests : trim(lower("${try(v.metadata.namespace, "")}-${v.metadata.name}"), "-") => v if v.kind == "Deployment"
  }

  manifest = each.value

  depends_on = [
    kubernetes_manifest.config_map,
    kubernetes_manifest.role_binding,
    kubernetes_manifest.service_account,
  ]
}

resource "kubernetes_manifest" "unknown" {
  for_each = {
    for v in local.manifests : trim(lower("${try(v.metadata.namespace, "")}-${v.metadata.name}"), "-") => v if !contains(local.known_resources, v.kind)
  }

  manifest = each.value

  depends_on = [
    kubernetes_manifest.daemon_set,
    kubernetes_manifest.deployment,
    kubernetes_manifest.config_map,
    kubernetes_manifest.role_binding,
    kubernetes_manifest.service,
  ]
}
