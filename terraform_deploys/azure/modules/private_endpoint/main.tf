resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoint_service_ids

  location            = var.location_input
  name                = "${var.name_prefix_input}-${each.key}"
  resource_group_name = var.resource_group_name_input
  subnet_id           = var.subnet_id_input

  private_service_connection {
    name                           = "${var.private_service_connection_name_prefix_input}-${each.key}"
    private_connection_resource_id = each.value
    subresource_names              = var.subresource_names_input
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = var.private_dns_zone_group_name_input
    private_dns_zone_ids = var.private_dns_zone_ids_input
  }
}
