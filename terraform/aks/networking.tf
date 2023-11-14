module "vnet" {
  source = "./modules/virtual_network"

  resource_group_name = module.rg.name
  name                = "vnet-${var.identifier}-example"
  address_spaces      = ["10.30.0.0/16"]

  tags = {
    "ManagedBy" = "Terraform"
  }


  depends_on = [module.rg]
}

module "subnet" {
  source = "./modules/subnet"

  name                 = "snet-${var.identifier}-example"
  resource_group_name  = module.rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.30.0.0/21"]

  depends_on = [
    module.vnet
  ]
}

resource "azurerm_private_dns_zone" "main" {
  name                = "privatelink.northeurope.azmk8s.io"
  resource_group_name = module.rg.name
}
