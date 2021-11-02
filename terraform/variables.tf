variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
  ]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::740877495907:role/AWSReservedSSO_AdministratorAccess_f8a30ed3ca508212"
      username = "sso-admin"
      groups   = ["system:masters"]
    }
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::740877495907:user/benny"
      username = "benny"
      groups   = ["system:masters"]
    },
  ]
}

variable "domain_name" {
  description = "DNS domain name to be used within this environment (e.g. example.com). You need a matching Route53 zone for this domain"
  type        = string

  default = "k8s-training.aws-tests.skyworkz.nl"
}


