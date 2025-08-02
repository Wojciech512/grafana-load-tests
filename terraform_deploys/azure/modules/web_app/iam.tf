resource "azurerm_role_assignment" "this" {
  for_each = azurerm_linux_web_app.this

  scope                = var.acr_registry_id_input
  role_definition_name = var.role_definition_name_input
  principal_id         = each.value.identity[0].principal_id
}
