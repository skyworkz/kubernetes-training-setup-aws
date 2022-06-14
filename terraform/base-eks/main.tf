provider "aws" {
  region = local.region
}

locals {
  name            = "skyworkz-k8s-training-${random_string.suffix.result}"
  cluster_version = "1.20"
  region          = "eu-west-1"
}

################################################################################
# Supporting Resources
################################################################################

data "aws_availability_zones" "available" {
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name                 = local.name
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets      = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = "1"
  }

  tags = {
    GithubRepo = "kubernetes-training-setup-aws"
    GithubOrg  = "skyworkz"
  }
}
################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 17.22.0, < 18.0"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa = true

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  node_groups = {
    spot1 = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 0

      instance_types = ["m5.large"]
      capacity_type  = "SPOT"
      k8s_labels = {
        NodeGroup = "spot1"
      }
      additional_tags = {
        NodeType = "spot"
      }
      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }
    od1 = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_types = ["m5.large"]
      k8s_labels = {
        NodeGroup = "od1"
      }
      additional_tags = {
        NodeType = "ondemand"
      }
      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }
    pe = {
      desired_capacity = 2
      max_capacity     = 4
      min_capacity     = 1

      instance_types = ["m5.large"]
      k8s_labels = {
        tenant    = "kubetrain"
        NodeGroup = "pe"
      }
      additional_tags = {
        NodeType = "ondemand"
      }
      taints = [
        {
          key    = "tenant"
          value  = "kubetrain"
          effect = "NO_SCHEDULE"
        }
      ]
      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }

  }

  map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts

  tags = {
    GithubRepo = "kubernetes-training-setup-aws"
    GithubOrg  = "skyworkz"
  }
}

################################################################################
# Kubernetes provider configuration
################################################################################

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

resource "local_sensitive_file" "k8s-svc_tfvars" {
  filename = "../k8s-svc/terraform.tfvars"
  content  = <<EOT
  eks_cluster_id        = "${module.eks.cluster_id}"
  eks_oidc_issuer_url   = "${module.eks.cluster_oidc_issuer_url}"
  eks_oidc_provider_arn = "${module.eks.oidc_provider_arn}"

  external_dns_domain_name = "${var.domain_name}"
EOT
}
