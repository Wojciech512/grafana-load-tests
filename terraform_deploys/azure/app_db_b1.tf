# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# App Service Plan B1
resource "azurerm_service_plan" "b1" {
  name                = "asp-b1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "B_Standard_B1ms"
}

# Web App for Containers
resource "azurerm_app_service" "b1" {
  name                = "app-b1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_service_plan.b1.id

  site_config {
    linux_fx_version = "DOCKER|${var.container_image}"
  }

  app_settings = {
    DATABASE_HOST     = azurerm_postgresql_flexible_server.b1.fqdn
    DATABASE_NAME     = "appdb"
    DATABASE_USER     = var.AZURE_POSTGRESQL_USERNAME
    DATABASE_PASSWORD = var.AZURE_POSTGRESQL_PASSWORD
    DATABASE_PORT     = "5432"
  }
}

# Virtual Network + Subnet dla Private Endpoint
resource "azurerm_virtual_network" "db" {
  name                = "vnet-db-b1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "subnet-db-b1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.db.name
  address_prefixes     = ["10.0.1.0/26"]
  service_endpoints    = ["Microsoft.DBforPostgreSQL"]
}

# PostgreSQL Flexible Server B1ms
resource "azurerm_postgresql_flexible_server" "b1" {
  name                  = "pgflex-b1"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  version               = "16"
  sku_name              = "Standard_B1ms"
  delegated_subnet_id   = azurerm_subnet.db.id
  storage_mb            = 32768
  backup_retention_days = 7

  administrator_login    = var.AZURE_POSTGRESQL_USERNAME
  administrator_password = var.AZURE_POSTGRESQL_PASSWORD

  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }

  lifecycle {
    ignore_changes = [
      zone,
    ]
  }
}


# Private Endpoint + DNS
resource "azurerm_private_endpoint" "b1_db" {
  name                = "pe-db-b1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.db.id

  private_service_connection {
    name                           = "psc-db-b1"
    private_connection_resource_id = azurerm_postgresql_flexible_server.b1.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "postgresql" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "db_link" {
  name                  = "link-db-b1-vnet"
  resource_group_name   = azurerm_resource_group.main.name
  virtual_network_id    = azurerm_virtual_network.db.id
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
}

resource "azurerm_private_dns_a_record" "db" {
  name                = azurerm_postgresql_flexible_server.b1.name
  zone_name           = azurerm_private_dns_zone.postgresql.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.b1_db.private_service_connection[0].private_ip_address]
}

# Użytkownik proxy w bazie
provider "postgresql" {
  alias    = "b1"
  host     = azurerm_private_dns_a_record.db.records[0]
  username = var.AZURE_POSTGRESQL_USERNAME
  password = var.AZURE_POSTGRESQL_PASSWORD
  sslmode  = "require"
}

resource "postgresql_role" "proxy_b1" {
  provider = postgresql.b1
  name     = var.PROXY_DB_USERNAME
  password = var.PROXY_DB_PASSWORD
  login    = true
}

resource "postgresql_grant" "proxy_access_b1" {
  provider    = postgresql.b1
  role_name   = postgresql_role.proxy_b1.name
  database    = "appdb"
  object_type = "database"
  privileges  = ["CONNECT"]
}
