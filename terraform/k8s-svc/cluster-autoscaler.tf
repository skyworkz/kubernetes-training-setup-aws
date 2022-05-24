#
# IAM / IRSA
# We leverage IRSA in order to link Kubernetes deployments to AWS IAM roles
# More info: https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/
#
data "aws_iam_policy_document" "cluster_autoscaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = [var.eks_oidc_provider_arn]
      type        = "Federated"
    }
  }
}

data "aws_iam_policy_document" "cluster_autoscaler_policy" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    effect = "Allow"

    resources = ["*"]
  }
}

resource "aws_iam_role" "cluster_autoscaler_role" {
  name               = "cluster-autoscaler-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role_policy.json

  inline_policy {
    name   = "cluster-autoscaler-policy"
    policy = data.aws_iam_policy_document.cluster_autoscaler_policy.json
  }
}

#
# Kubernetes Resources
#
resource "kubernetes_manifest" "serviceaccount_kube_system_cluster_autoscaler" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "annotations" = {
        "eks.amazonaws.com/role-arn" = "${aws_iam_role.cluster_autoscaler_role.arn}"
      }
      "labels" = {
        "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
        "k8s-app"   = "cluster-autoscaler"
      }
      "name"      = "cluster-autoscaler"
      "namespace" = "kube-system"
    }
  }
}

resource "kubernetes_manifest" "clusterrole_cluster_autoscaler" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRole"
    "metadata" = {
      "labels" = {
        "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
        "k8s-app"   = "cluster-autoscaler"
      }
      "name" = "cluster-autoscaler"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "events",
          "endpoints",
        ]
        "verbs" = [
          "create",
          "patch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods/eviction",
        ]
        "verbs" = [
          "create",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods/status",
        ]
        "verbs" = [
          "update",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resourceNames" = [
          "cluster-autoscaler",
        ]
        "resources" = [
          "endpoints",
        ]
        "verbs" = [
          "get",
          "update",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes",
        ]
        "verbs" = [
          "watch",
          "list",
          "get",
          "update",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "namespaces",
          "pods",
          "services",
          "replicationcontrollers",
          "persistentvolumeclaims",
          "persistentvolumes",
        ]
        "verbs" = [
          "watch",
          "list",
          "get",
        ]
      },
      {
        "apiGroups" = [
          "extensions",
        ]
        "resources" = [
          "replicasets",
          "daemonsets",
        ]
        "verbs" = [
          "watch",
          "list",
          "get",
        ]
      },
      {
        "apiGroups" = [
          "policy",
        ]
        "resources" = [
          "poddisruptionbudgets",
        ]
        "verbs" = [
          "watch",
          "list",
        ]
      },
      {
        "apiGroups" = [
          "apps",
        ]
        "resources" = [
          "statefulsets",
          "replicasets",
          "daemonsets",
        ]
        "verbs" = [
          "watch",
          "list",
          "get",
        ]
      },
      {
        "apiGroups" = [
          "storage.k8s.io",
        ]
        "resources" = [
          "storageclasses",
          "csinodes",
          "csidrivers",
          "csistoragecapacities",
        ]
        "verbs" = [
          "watch",
          "list",
          "get",
        ]
      },
      {
        "apiGroups" = [
          "batch",
          "extensions",
        ]
        "resources" = [
          "jobs",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "patch",
        ]
      },
      {
        "apiGroups" = [
          "coordination.k8s.io",
        ]
        "resources" = [
          "leases",
        ]
        "verbs" = [
          "create",
        ]
      },
      {
        "apiGroups" = [
          "coordination.k8s.io",
        ]
        "resourceNames" = [
          "cluster-autoscaler",
        ]
        "resources" = [
          "leases",
        ]
        "verbs" = [
          "get",
          "update",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "role_kube_system_cluster_autoscaler" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "Role"
    "metadata" = {
      "labels" = {
        "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
        "k8s-app"   = "cluster-autoscaler"
      }
      "name"      = "cluster-autoscaler"
      "namespace" = "kube-system"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "configmaps",
        ]
        "verbs" = [
          "create",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resourceNames" = [
          "cluster-autoscaler-status",
          "cluster-autoscaler-priority-expander",
        ]
        "resources" = [
          "configmaps",
        ]
        "verbs" = [
          "delete",
          "get",
          "update",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_cluster_autoscaler" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
        "k8s-app"   = "cluster-autoscaler"
      }
      "name" = "cluster-autoscaler"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind"     = "ClusterRole"
      "name"     = "cluster-autoscaler"
    }
    "subjects" = [
      {
        "kind"      = "ServiceAccount"
        "name"      = "cluster-autoscaler"
        "namespace" = "kube-system"
      },
    ]
  }
}

resource "kubernetes_manifest" "rolebinding_kube_system_cluster_autoscaler" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "RoleBinding"
    "metadata" = {
      "labels" = {
        "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
        "k8s-app"   = "cluster-autoscaler"
      }
      "name"      = "cluster-autoscaler"
      "namespace" = "kube-system"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind"     = "Role"
      "name"     = "cluster-autoscaler"
    }
    "subjects" = [
      {
        "kind"      = "ServiceAccount"
        "name"      = "cluster-autoscaler"
        "namespace" = "kube-system"
      },
    ]
  }
}

resource "kubernetes_manifest" "deployment_kube_system_cluster_autoscaler" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "cluster-autoscaler"
      }
      "name"      = "cluster-autoscaler"
      "namespace" = "kube-system"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "cluster-autoscaler"
        }
      }
      "template" = {
        "metadata" = {
          "annotations" = {
            "prometheus.io/port"   = "8085"
            "prometheus.io/scrape" = "true"
          }
          "labels" = {
            "app" = "cluster-autoscaler"
          }
        }
        "spec" = {
          "containers" = [
            {
              "command" = [
                "./cluster-autoscaler",
                "--v=4",
                "--stderrthreshold=info",
                "--cloud-provider=aws",
                "--skip-nodes-with-local-storage=false",
                "--skip-nodes-with-system-pods",
                "--balance-similar-node-groups",
                "--expander=least-waste",
                "--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${var.eks_cluster_id}",
              ]
              "image"           = "k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0"
              "imagePullPolicy" = "Always"
              "name"            = "cluster-autoscaler"
              "resources" = {
                "limits" = {
                  "cpu"    = "100m"
                  "memory" = "600Mi"
                }
                "requests" = {
                  "cpu"    = "100m"
                  "memory" = "600Mi"
                }
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/ssl/certs/ca-certificates.crt"
                  "name"      = "ssl-certs"
                  "readOnly"  = true
                },
              ]
            },
          ]
          "priorityClassName" = "system-cluster-critical"
          "securityContext" = {
            "fsGroup"      = 65534
            "runAsNonRoot" = true
            "runAsUser"    = 65534
          }
          "serviceAccountName" = "cluster-autoscaler"
          "nodeSelector" = {
            "eks.amazonaws.com/capacityType" = "ON_DEMAND"
            "kubernetes.io/os"               = "linux"
            "tenant"                         = "kubetrain"
          }
          "tolerations" = [
            {
              "effect"   = "NoSchedule"
              "key"      = "tenant"
              "operator" = "Equal"
              "value"    = "kubetrain"
            },
          ]
          "volumes" = [
            {
              "hostPath" = {
                "path" = "/etc/ssl/certs/ca-bundle.crt"
              }
              "name" = "ssl-certs"
            },
          ]
        }
      }
    }
  }
}
