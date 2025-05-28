data "azurerm_client_config" "current" {}

resource "azuread_application" "prom" {
  display_name = var.SP_NAME
}

resource "azuread_service_principal" "prom" {
  application_object_id = azuread_application.prom.object_id
}

resource "azuread_service_principal_password" "prom" {
  service_principal_id = azuread_service_principal.prom.id
  end_date             = "2099-01-01T00:00:00Z"
}

resource "azurerm_role_assignment" "prom_metrics" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Monitoring Reader"
  principal_id         = azuread_service_principal.prom.id
}
