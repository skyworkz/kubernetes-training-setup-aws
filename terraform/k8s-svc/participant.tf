resource "kubernetes_manifest" "clusterrole_kubetrain_participant" {
  manifest = {
    "aggregationRule" = {
      "clusterRoleSelectors" = [
        {
          "matchLabels" = {
            "rbac.authorization.k8s.io/aggregate-to-kubetrain-participant" = "true"
          }
        },
      ]
    }
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "kubetrain-participant"
    }
  }
}
