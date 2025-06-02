resource "azurerm_service_plan" "plan_b1" {
  name                = "${var.AZURE_POSTGRESQL_NAME}-${random_string.suffix.result}-plan-b1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "B1"
  os_type             = "Linux"
}

resource "azurerm_service_plan" "plan_b2" {
  name                = "${var.AZURE_POSTGRESQL_NAME}-${random_string.suffix.result}-plan-b1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "B2"
  os_type             = "Linux"
}

resource "azurerm_service_plan" "plan_b3" {
  name                = "${var.AZURE_POSTGRESQL_NAME}-${random_string.suffix.result}-plan-b1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "B3"
  os_type             = "Linux"
}
