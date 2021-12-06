#
# IAM / IRSA
# We leverage IRSA in order to link Kubernetes deployments to AWS IAM roles
# More info: https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/
#
data "aws_iam_policy_document" "external_dns_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:external-dns:external-dns-sa"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

data "aws_iam_policy_document" "external_dns_policy" {
  statement {
    actions = ["route53:ChangeResourceRecordSets"]
    effect  = "Allow"

    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
    effect = "Allow"

    resources = ["*"]
  }
}

resource "aws_iam_role" "external_dns_role" {
  name               = "external-dns-role"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role_policy.json

  inline_policy {
    name   = "external-dns-policy"
    policy = data.aws_iam_policy_document.external_dns_policy.json
  }
}

#
# Kubernetes Resources
#
resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_manifest" "serviceaccount_external_dns" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "annotations" = {
        "eks.amazonaws.com/role-arn" = "${aws_iam_role.external_dns_role.arn}"
      }
      "name"      = "external-dns-sa"
      "namespace" = "${kubernetes_namespace.external-dns.metadata.0.name}"
    }
  }
}

resource "kubernetes_manifest" "clusterrole_external_dns" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRole"
    "metadata" = {
      "name" = "external-dns"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "services",
          "endpoints",
          "pods",
        ]
        "verbs" = [
          "get",
          "watch",
          "list",
        ]
      },
      {
        "apiGroups" = [
          "extensions",
          "networking.k8s.io",
        ]
        "resources" = [
          "ingresses",
        ]
        "verbs" = [
          "get",
          "watch",
          "list",
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
          "list",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_external_dns_viewer" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRoleBinding"
    "metadata" = {
      "name" = "external-dns-viewer"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind"     = "ClusterRole"
      "name"     = "external-dns"
    }
    "subjects" = [
      {
        "kind"      = "ServiceAccount"
        "name"      = "external-dns-sa"
        "namespace" = "${kubernetes_namespace.external-dns.metadata.0.name}"
      },
    ]
  }
}

resource "kubernetes_manifest" "deployment_external_dns" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "name"      = "external-dns"
      "namespace" = "${kubernetes_namespace.external-dns.metadata.0.name}"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "external-dns"
        }
      }
      "strategy" = {
        "type" = "Recreate"
      }
      "template" = {
        "metadata" = {
          "annotations" = {
            "iam.amazonaws.com/role" = "${aws_iam_role.external_dns_role.arn}"
          }
          "labels" = {
            "app" = "external-dns"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--source=service",
                "--source=ingress",
                "--domain-filter=${var.domain_name}",
                "--provider=aws",
                "--policy=upsert-only",
                "--aws-zone-type=public",
                "--registry=txt",
                "--txt-owner-id=my-hostedzone-identifier",
              ]
              "image" = "k8s.gcr.io/external-dns/external-dns:v0.7.6"
              "name"  = "external-dns"
            },
          ]
          "securityContext" = {
            "fsGroup" = 65534
          }
          "serviceAccountName" = "external-dns-sa"
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
        }
      }
    }
  }
}

