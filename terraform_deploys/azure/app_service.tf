resource "azurerm_linux_web_app" "web_b1ms" {
  name                = "${var.AZURE_POSTGRESQL_NAME}-${random_string.suffix.result}-web-b1-linux"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan_b1.id

  site_config {
    linux_fx_version                        = "DOCKER|${azurerm_container_registry.acr.login_server}/moja-apka:v1"
    container_registry_use_managed_identity = true

    http2_enabled       = true
    minimum_tls_version = "1.2"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DATABASE_URL"                        = "postgresql://${var.AZURE_POSTGRESQL_USERNAME}:${var.AZURE_POSTGRESQL_PASSWORD}@${azurerm_postgresql_flexible_server.db_b1ms.fqdn}:5432/postgres?sslmode=require"
  }

  https_only = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "swift_web_b1ms" {
  app_service_id = azurerm_linux_web_app.web_b1ms.id
  subnet_id      = azurerm_subnet.db_subnet.id
}

resource "azurerm_linux_web_app" "web_b2s" {
  name                = "${var.AZURE_POSTGRESQL_NAME}-${random_string.suffix.result}-web-b2-linux"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan_b2.id

  site_config {
    linux_fx_version                        = "DOCKER|${azurerm_container_registry.acr.login_server}/moja-apka:v1"
    container_registry_use_managed_identity = true

    http2_enabled       = true
    minimum_tls_version = "1.2"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DATABASE_URL"                        = "postgresql://${var.AZURE_POSTGRESQL_USERNAME}:${var.AZURE_POSTGRESQL_PASSWORD}@${azurerm_postgresql_flexible_server.db_b2s.fqdn}:5432/postgres?sslmode=require"
  }

  https_only = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "swift_web_b2s" {
  app_service_id = azurerm_linux_web_app.web_b2s.id
  subnet_id      = azurerm_subnet.db_subnet.id
}

resource "azurerm_linux_web_app" "web_b2ms" {
  name                = "${var.AZURE_POSTGRESQL_NAME}-${random_string.suffix.result}-web-b3-linux"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan_b3.id

  site_config {
    linux_fx_version                        = "DOCKER|${azurerm_container_registry.acr.login_server}/moja-apka:v1"
    container_registry_use_managed_identity = true

    http2_enabled       = true
    minimum_tls_version = "1.2"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DATABASE_URL"                        = "postgresql://${var.AZURE_POSTGRESQL_USERNAME}:${var.AZURE_POSTGRESQL_PASSWORD}@${azurerm_postgresql_flexible_server.db_b2ms.fqdn}:5432/postgres?sslmode=require"
  }

  https_only = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "swift_web_b2ms" {
  app_service_id = azurerm_linux_web_app.web_b2ms.id
  subnet_id      = azurerm_subnet.db_subnet.id
}


locals {
  webapp_principals = {
    web_b1ms = azurerm_linux_web_app.web_b1ms.identity[0].principal_id
    web_b2s  = azurerm_linux_web_app.web_b2s.identity[0].principal_id
    web_b2ms = azurerm_linux_web_app.web_b2ms.identity[0].principal_id
  }
}

resource "azurerm_role_assignment" "webapp_acr_pull" {
  for_each             = local.webapp_principals
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = each.value
}
