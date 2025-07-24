resource "azurerm_postgresql_flexible_server_firewall_rule" "this" {
  for_each = var.firewall_rule_config_input

  name             = each.value.name_input
  server_id        = each.value.server_id_input
  start_ip_address = each.value.start_ip_address_input
  end_ip_address   = each.value.end_ip_address_input
}
