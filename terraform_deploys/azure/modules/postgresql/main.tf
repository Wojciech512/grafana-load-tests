resource "azurerm_postgresql_flexible_server" "this" {
  for_each = var.databases_config_input

  name     = "${each.key}-database-${var.random_string_input}"
  sku_name = each.value.sku_name_input

  resource_group_name           = var.resource_group_name_input
  location                      = var.location_input
  administrator_login           = var.administrator_login_input
  administrator_password        = var.administrator_password_input
  version                       = var.version_input
  storage_mb                    = var.storage_mb_input
  backup_retention_days         = var.backup_retention_days_input
  geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled_input
  public_network_access_enabled = var.public_network_access_enabled_input
  zone                          = "1"
  #  lifecycle {
  #    prevent_destroy = true
  #  }
}
