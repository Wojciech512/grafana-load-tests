resource "azurerm_service_plan" "this" {
  for_each = var.service_plan_config_input

  name                = "${each.key}-${var.random_string_input}-plan"
  location            = each.value.location_resource_group_input
  resource_group_name = each.value.resource_group_name_input
  os_type             = each.value.os_type_input
  sku_name            = each.value.sku_name_input
}
