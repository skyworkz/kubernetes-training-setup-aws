# #
# # IAM / IRSA
# # We leverage IRSA in order to link Kubernetes deployments to AWS IAM roles
# # More info: https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/
# #
# data "aws_iam_policy_document" "ebs_csi_driver_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:ebs-csi-controller"]
#     }

#     principals {
#       identifiers = [module.eks.oidc_provider_arn]
#       type        = "Federated"
#     }
#   }
# }

resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = module.eks.oidc_provider_arn
        },
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# resource "aws_iam_role" "ebs_csi_driver_role" {
#   name               = "ebs-csi-driver-role"
#   assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver_assume_role_policy.json

#   inline_policy {
#     name   = "ebs-csi-driver-policy"
#     policy = file("${path.module}/iam-policies/ebs-csi-driver-policy.json")
#   }
# }
