resource "azurerm_role_assignment" "acr_pull" {
  for_each             = azurerm_container_app.this
  scope                = var.acr_registry_id_input
  role_definition_name = var.role_definition_name_input
  principal_id         = each.value.identity[0].principal_id
}
