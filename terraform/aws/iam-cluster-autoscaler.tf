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
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "cluster_autoscaler_role" {
  name               = "cluster-autoscaler-role-${random_string.suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role_policy.json

  inline_policy {
    name   = "cluster-autoscaler-policy"
    policy = file("${path.module}/iam-policies/cluster-auto-scaler-policy.json")
  }
}
