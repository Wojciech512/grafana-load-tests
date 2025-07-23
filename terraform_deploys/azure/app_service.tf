locals {
  webapps_plans = {
    web-b1-linux = {
      sku_name = "B1"
    }
    web-b2-linux = {
      sku_name = "B2"
    }
    web-b3-linux = {
      sku_name = "B3"
    }
  }

  webapps_configs = {
    web-b1-linux = {
      database_host = azurerm_postgresql_flexible_server.database["db_b1ms-postgres"].name
    }
    web-b2-linux = {
      database_host = azurerm_postgresql_flexible_server.database["db_b2s-postgres"].name
    }
    web-b3-linux = {
      database_host = azurerm_postgresql_flexible_server.database["db_b2ms-postgres"].name
    }
  }

  common_webapp_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "PORT"                                = var.PORT
    "WEBSITES_PORT"                       = var.PORT

    "AZURE_POSTGRESQL_NAME"     = var.AZURE_POSTGRESQL_NAME
    "AZURE_POSTGRESQL_USERNAME" = var.AZURE_POSTGRESQL_USERNAME
    "AZURE_POSTGRESQL_PASSWORD" = var.AZURE_POSTGRESQL_PASSWORD
    "AZURE_POSTGRESQL_PORT"     = "5432"

    "DEBUG"                = var.DEBUG
    "ALLOWED_HOSTS"        = var.ALLOWED_HOSTS
    "SECRET_KEY"           = var.SECRET_KEY
    "EMAIL_HOST_USER"      = var.EMAIL_HOST_USER
    "EMAIL_HOST_PASSWORD"  = var.EMAIL_HOST_PASSWORD
    "CSRF_TRUSTED_ORIGINS" = var.CSRF_TRUSTED_ORIGINS
  }

  webapp_principals = {
    for name, web in azurerm_linux_web_app.webapp :
    name => web.identity[0].principal_id
  }
}

resource "azurerm_service_plan" "plans" {
  for_each = local.webapps_plans

  name                = "${each.key}-${random_string.suffix.result}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = each.value.sku_name
}

resource "azurerm_linux_web_app" "webapp" {
  for_each = local.webapps_configs

  name                = "${each.key}-${random_string.suffix.result}-webapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plans[each.key].id
  https_only          = true

  app_settings = merge(
    local.common_webapp_settings,
    {
      "AZURE_POSTGRESQL_HOST" = "${each.value.database_host}.privatelink.postgres.database.azure.com"
    }
  )

  site_config {
    vnet_route_all_enabled = true

    application_stack {
      docker_image_name   = "ecommerce-app:latest"
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
    }

    container_registry_use_managed_identity = true
    http2_enabled                           = true
    minimum_tls_version                     = "1.2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "webapp_swifts" {
  for_each = azurerm_linux_web_app.webapp

  app_service_id = each.value.id
  subnet_id      = azurerm_subnet.app_subnet.id
}

resource "azurerm_role_assignment" "webapp_acr_pull" {
  for_each = local.webapp_principals

  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = each.value
}
