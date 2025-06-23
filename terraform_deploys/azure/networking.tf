resource "azurerm_virtual_network" "main_vnet" {
  name                = "${var.AZURE_POSTGRESQL_NAME}-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "db_subnet" {
  name                 = "postgres-db-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = ["10.1.1.0/24"]

  delegation {
    name = "delegation-db"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

