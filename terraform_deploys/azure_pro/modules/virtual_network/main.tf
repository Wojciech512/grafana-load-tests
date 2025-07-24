resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name_input
  address_space       = var.address_space_input
  dns_servers         = var.dns_servers_input
  resource_group_name = var.resource_group_name_input
  location            = var.resource_group_location_input
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets_input

  name                 = each.key
  address_prefixes     = each.value.address_prefixes_input
  virtual_network_name = azurerm_virtual_network.this.name
  resource_group_name  = var.resource_group_name_input


  dynamic "delegation" {
    for_each = length(each.value.delegation_name_input) > 0 ? [each.value] : []
    content {
      name = each.value.delegation_name_input
      service_delegation {
        name    = each.value.service_name_input
        actions = each.value.service_actions_input
      }
    }
  }
}
