resource "azurerm_private_endpoint" "pe_db_b1ms" {
  name                = "${var.AZURE_POSTGRESQL_NAME}-${random_string.suffix.result}-pe-b1ms"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  subnet_id = azurerm_subnet.db_subnet.id

  private_service_connection {
    name                           = "psc-db-b1ms"
    private_connection_resource_id = azurerm_postgresql_flexible_server.db_b1ms.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "pe_db_b2s" {
  name                = "${var.AZURE_POSTGRESQL_NAME}-${random_string.suffix.result}-pe-b2s"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  subnet_id = azurerm_subnet.db_subnet.id

  private_service_connection {
    name                           = "psc-db-b2s"
    private_connection_resource_id = azurerm_postgresql_flexible_server.db_b2s.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "pe_db_b2ms" {
  name                = "${var.AZURE_POSTGRESQL_NAME}-${random_string.suffix.result}-pe-b2ms"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  subnet_id = azurerm_subnet.db_subnet.id

  private_service_connection {
    name                           = "psc-db-b2ms"
    private_connection_resource_id = azurerm_postgresql_flexible_server.db_b2ms.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
}
