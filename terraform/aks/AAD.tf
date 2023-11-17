data "azuread_client_config" "current" {}

data "azuread_user" "aad" {
  user_principal_name = "robert@skyworkz.nl"
}

resource "azuread_group" "k8sadmins" {
  display_name = "Kubernetes Admins"
  members = [
    data.azuread_user.aad.object_id,
    data.azuread_client_config.current.object_id
  ]
  security_enabled = true
}

resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = module.rg.name
  location            = module.rg.location

  name = "identity-${var.identifier}-example"
}

resource "azurerm_role_assignment" "network" {
  scope                = module.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

resource "azurerm_role_assignment" "dns" {
  scope                = azurerm_private_dns_zone.main.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}
