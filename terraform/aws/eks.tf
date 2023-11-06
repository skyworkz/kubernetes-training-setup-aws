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
    # spot1 = {
    #   desired_capacity = 1
    #   max_capacity     = 10
    #   min_capacity     = 0

    #   instance_types = ["m5.large"]
    #   capacity_type  = "SPOT"
    #   k8s_labels = {
    #     NodeGroup = "spot1"
    #   }
    #   additional_tags = {
    #     NodeType = "spot"
    #   }
    #   update_config = {
    #     max_unavailable_percentage = 50 # or set `max_unavailable`
    #   }
    # }
    # od1 = {
    #   desired_capacity = 1
    #   max_capacity     = 10
    #   min_capacity     = 0

    #   instance_types = ["m5.large"]
    #   k8s_labels = {
    #     NodeGroup = "od1"
    #   }
    #   additional_tags = {
    #     NodeType = "ondemand"
    #   }
    #   update_config = {
    #     max_unavailable_percentage = 50 # or set `max_unavailable`
    #   }
    # }
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
    b1 = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_types = ["t3.medium"]
      k8s_labels = {
        NodeGroup       = "b1"
        NodePerformance = "burst"
      }
      additional_tags = {
        NodeType = "ondemand"
      }
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
