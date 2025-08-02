resource "azurerm_container_registry" "this" {
  name                = "${var.name_input}${var.random_string_input}"
  location            = var.location_input
  sku                 = var.sku_input
  resource_group_name = var.resource_group_name_input
  admin_enabled       = var.admin_enabled_input
}

