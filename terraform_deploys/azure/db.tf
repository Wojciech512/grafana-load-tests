locals {
  version               = "13"
  storage_mb            = 32768
  backup_retention      = 7
  geo_redundant_backups = false
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_postgresql_flexible_server" "db_b1ms" {
  name                = "${var.AZURE_POSTGRESQL_NAME}-${random_string.suffix.result}-b1ms"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku_name = "B_Standard_B1ms"
  version  = local.version

  administrator_login          = var.AZURE_POSTGRESQL_USERNAME
  administrator_password       = var.AZURE_POSTGRESQL_PASSWORD
  storage_mb                   = local.storage_mb
  backup_retention_days        = local.backup_retention
  geo_redundant_backup_enabled = local.geo_redundant_backups

  public_network_access_enabled = true

  lifecycle {
    ignore_changes = [
      zone,
      high_availability.0.standby_availability_zone
    ]
  }
}

resource "azurerm_postgresql_flexible_server" "db_b2s" {
  name                = "${var.AZURE_POSTGRESQL_NAME}-${random_string.suffix.result}-b2s"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku_name = "B_Standard_B2s"
  version  = local.version

  administrator_login          = var.AZURE_POSTGRESQL_USERNAME
  administrator_password       = var.AZURE_POSTGRESQL_PASSWORD
  storage_mb                   = local.storage_mb
  backup_retention_days        = local.backup_retention
  geo_redundant_backup_enabled = local.geo_redundant_backups

  public_network_access_enabled = true

  lifecycle {
    ignore_changes = [
      zone,
      high_availability.0.standby_availability_zone
    ]
  }
}

resource "azurerm_postgresql_flexible_server" "db_b2ms" {
  name                = "${var.AZURE_POSTGRESQL_NAME}-${random_string.suffix.result}-b2ms"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku_name = "B_Standard_B2ms"
  version  = local.version

  administrator_login          = var.AZURE_POSTGRESQL_USERNAME
  administrator_password       = var.AZURE_POSTGRESQL_PASSWORD
  storage_mb                   = local.storage_mb
  backup_retention_days        = local.backup_retention
  geo_redundant_backup_enabled = local.geo_redundant_backups

  public_network_access_enabled = true

  lifecycle {
    ignore_changes = [
      zone,
      high_availability.0.standby_availability_zone
    ]
  }
}
