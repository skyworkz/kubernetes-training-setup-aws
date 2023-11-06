provider "aws" {
  region = local.region
}

# Kubernetes provider
# Apparently, this is necessary within the AWS EKS module...
# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v12.1.0/README.md#usage-example

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
