resource "azurerm_private_dns_zone" "this" {
  name                = "${var.name_input}${var.random_string_input}"
  resource_group_name = var.resource_group_name_input
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = var.name_link_input
  resource_group_name   = var.resource_group_name_input
  virtual_network_id    = var.virtual_network_id_input
  private_dns_zone_name = azurerm_private_dns_zone.this.name
}

