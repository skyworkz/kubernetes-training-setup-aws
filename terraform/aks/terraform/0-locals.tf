locals {
  env                 = "dev"
  region              = "northeurope"
  resource_group_name = "tutorial"
  aks_name            = "aks-training-${local.env}"
  aks_version         = "1.27"
}
