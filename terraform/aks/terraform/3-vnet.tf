resource "azurerm_virtual_network" "this" {
  name                = "skyworkz-vnet-${local.env}-main"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  tags = {
    env = local.env
  }
}
