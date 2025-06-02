resource "azurerm_private_dns_zone" "pg_zone_b1ms" {
  name                = azurerm_postgresql_flexible_server.db_b1ms.fqdn
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_pg_b1ms" {
  name                  = "link-pg-b1ms-private-dns"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pg_zone_b1ms.name
  virtual_network_id    = azurerm_virtual_network.main_vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone" "pg_zone_b2s" {
  name                = azurerm_postgresql_flexible_server.db_b2s.fqdn
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_pg_b2s" {
  name                  = "link-pg-b2s-private-dns"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pg_zone_b2s.name
  virtual_network_id    = azurerm_virtual_network.main_vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone" "pg_zone_b2ms" {
  name                = azurerm_postgresql_flexible_server.db_b2ms.fqdn
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_pg_b2ms" {
  name                  = "link-pg-b2ms-private-dns"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pg_zone_b2ms.name
  virtual_network_id    = azurerm_virtual_network.main_vnet.id
  registration_enabled  = false
}
