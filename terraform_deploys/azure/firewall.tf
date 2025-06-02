resource "azurerm_postgresql_flexible_server_firewall_rule" "fw_open_db_b1ms" {
  name             = "allow_all_b1ms"
  server_id        = azurerm_postgresql_flexible_server.db_b1ms.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "fw_open_db_b2s" {
  name             = "allow_all_b2s"
  server_id        = azurerm_postgresql_flexible_server.db_b2s.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "fw_open_db_b2ms" {
  name             = "allow_all_b2ms"
  server_id        = azurerm_postgresql_flexible_server.db_b2ms.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
