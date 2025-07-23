resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres_link" {
  name                  = "link-postgres-dns"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.postgres_vnet.id

  depends_on = [
    azurerm_virtual_network.postgres_vnet
  ]
}

resource "azurerm_private_endpoint" "postgres_pe" {
  for_each = {
    db_b1ms = azurerm_postgresql_flexible_server.database["db_b1ms-postgres"].id
    db_b2s  = azurerm_postgresql_flexible_server.database["db_b2s-postgres"].id
    db_b2ms = azurerm_postgresql_flexible_server.database["db_b2ms-postgres"].id
  }
  name                = "private-endpoint-postgres-${each.key}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.pe_subnet.id

  private_service_connection {
    name                           = "private-service-connection-postgres-${each.key}"
    private_connection_resource_id = each.value
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgres.id]
  }
}

