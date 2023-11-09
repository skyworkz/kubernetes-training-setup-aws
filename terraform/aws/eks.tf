################################################################################
# EKS Module
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.19.0"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id  = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns    = {}
    kube-proxy = {}
  }

  kms_key_administrators = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]

  enable_irsa = true

  cluster_enabled_log_types = [
    # "api",
    # "audit",
    # "authenticator",
    # "controllerManager",
    "scheduler"
  ]

  cloudwatch_log_group_retention_in_days = 5
  iam_role_name   = local.name

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium", "t3.large"]
     # Needed by the aws-ebs-csi-driver
    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
  }

  eks_managed_node_groups = {
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

  # aws-auth configmap
  manage_aws_auth_configmap = true
  aws_auth_roles    = var.aws_auth_roles
  aws_auth_users    = var.aws_auth_users

  tags = {
    GithubRepo = "kubernetes-training-setup-aws"
    GithubOrg  = "skyworkz"
  }
}
