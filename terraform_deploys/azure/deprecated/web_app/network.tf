resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  for_each = azurerm_linux_web_app.this

  app_service_id = each.value.id
  subnet_id      = var.subnet_id_input
}
