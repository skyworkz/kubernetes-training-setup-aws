resource "azurerm_subnet" "subnet-public" {
  name                 = "subnet-public"
  address_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_subnet" "subnet-private" {
  name                 = "subnet-private"
  address_prefixes     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

# If you want to use existing subnet
# data "azurerm_subnet" "subnet1" {
#   name                 = "subnet1"
#   virtual_network_name = "main"
#   resource_group_name  = "tutorial"
# }

# output "subnet_id" {
#   value = data.azurerm_subnet.subnet1.id
# }
