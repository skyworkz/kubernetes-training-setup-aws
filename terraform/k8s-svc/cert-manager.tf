#
# IAM / IRSA
# We leverage IRSA in order to link Kubernetes deployments to AWS IAM roles
# More info: https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/
#
data "aws_iam_policy_document" "cert_manager_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:cert-manager:cert-manager"]
    }

    principals {
      identifiers = [var.eks_oidc_provider_arn]
      type        = "Federated"
    }
  }
}

data "aws_iam_policy_document" "cert_manager_policy" {
  statement {
    actions = ["route53:ChangeResourceRecordSets"]
    effect  = "Allow"

    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListResourceRecordSets",
    ]
    effect = "Allow"

    resources = ["*"]
  }

  statement {
    actions = ["route53:GetChange"]
    effect  = "Allow"

    resources = ["arn:aws:route53:::change/*"]
  }
}

resource "aws_iam_role" "cert_manager_role" {
  name               = "cert-manager-role"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_assume_role_policy.json

  inline_policy {
    name   = "cert-manager-policy"
    policy = data.aws_iam_policy_document.cert_manager_policy.json
  }
}

output "cert_manager_role_arn" {
  value = aws_iam_role.cert_manager_role.arn
}


