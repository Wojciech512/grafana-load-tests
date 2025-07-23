locals {
  database_config = {
    db_b1ms-postgres = {
      sku_name = "B_Standard_B1ms"
    }
    db_b2s-postgres = {
      sku_name = "B_Standard_B2s"
    }
    db_b2ms-postgres = {
      sku_name = "B_Standard_B2ms"
    }
  }
}

resource "azurerm_postgresql_flexible_server" "database" {
  for_each = local.database_config

  name     = "${each.key}-${random_string.suffix.result}-database"
  sku_name = each.value.sku_name

  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  administrator_login           = var.AZURE_POSTGRESQL_USERNAME
  administrator_password        = var.AZURE_POSTGRESQL_PASSWORD
  version                       = "16"
  storage_mb                    = 32768
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = true

  lifecycle {
    ignore_changes = [
      zone,
      high_availability.0.standby_availability_zone
    ]
  }
}
