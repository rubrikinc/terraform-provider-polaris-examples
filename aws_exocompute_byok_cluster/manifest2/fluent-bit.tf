# Fluent-bit forward logs from the Kubernetes cluster to RSC. To receive as much
# log information as possible, it's important that fluent-bit starts first.

locals {
  fluent_bit_names = [
    "fluent-bit",
    "fluent-bit-read",
    "fluent-bit-config",
    "fluentd-config",
  ]

  # Filter the provided manifest, keeping only fluent-bit manifests.
  manifests_fluent_bit = [
    for v in [
      for v in split("---", var.manifest) : yamldecode(v)
    ] : v if contains(local.fluent_bit_names, v.metadata.name)
  ]
}

resource "kubernetes_manifest" "serviceaccount_fluent_bit" {
  manifest = one([for v in local.manifests_fluent_bit : v if v.kind == "ServiceAccount"])

  computed_fields = [
    "metadata.annotations",
    "metadata.labels",
  ]

  depends_on = [
    kubernetes_manifest.namespace,
  ]
}

resource "kubernetes_manifest" "clusterrole_fluent_bit" {
  manifest = one([for v in local.manifests_fluent_bit : v if v.kind == "ClusterRole"])

  computed_fields = [
    "metadata.annotations",
    "metadata.labels",
  ]

  depends_on = [
    kubernetes_manifest.namespace,
  ]
}

resource "kubernetes_manifest" "clusterrolebinding_fluent_bit" {
  manifest = one([for v in local.manifests_fluent_bit : v if v.kind == "ClusterRoleBinding"])

  computed_fields = [
    "metadata.annotations",
    "metadata.labels",
  ]

  depends_on = [
    kubernetes_manifest.serviceaccount_fluent_bit,
    kubernetes_manifest.clusterrole_fluent_bit,
  ]
}

resource "kubernetes_manifest" "configmap_fluent_bit" {
  for_each = {
    for v in local.manifests_fluent_bit : v.metadata.name => v if v.kind == "ConfigMap"
  }

  manifest = each.value

  computed_fields = [
    "metadata.annotations",
    "metadata.labels",
  ]

  depends_on = [
    kubernetes_manifest.namespace,
  ]
}

resource "kubernetes_manifest" "daemonset_fluent_bit" {
  manifest = one([for v in local.manifests_fluent_bit : v if v.kind == "DaemonSet"])

  computed_fields = [
    "metadata.annotations",
    "metadata.labels",
  ]

  depends_on = [
    kubernetes_manifest.clusterrolebinding_fluent_bit,
    kubernetes_manifest.configmap_fluent_bit,
    kubernetes_manifest.serviceaccount_fluent_bit,
  ]
}
