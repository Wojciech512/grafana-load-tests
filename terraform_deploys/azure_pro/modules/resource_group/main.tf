resource "azurerm_resource_group" "this" {
  name     = var.name_input
  location = var.location_input
}
