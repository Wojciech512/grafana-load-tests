resource "azurerm_linux_web_app" "this" {
  for_each = var.web_app_config_input

  name                = "${each.key}-${var.random_string_input}"
  service_plan_id     = each.value.service_plan_id_input
  location            = var.location_input
  resource_group_name = var.resource_group_name_input
  https_only          = var.https_only_input

  app_settings = merge(
    var.common_app_settings_input, {
      AZURE_POSTGRESQL_HOST = "${each.value.database_host_input}.privatelink.postgres.database.azure.com"
  })

  site_config {
    vnet_route_all_enabled = var.vnet_route_all_enabled_input

    application_stack {
      docker_image_name   = var.docker_image_name_input
      docker_registry_url = var.docker_registry_url_input
    }

    container_registry_use_managed_identity = var.container_registry_use_managed_identity_input
    http2_enabled                           = var.http2_enabled_input
    minimum_tls_version                     = var.minimum_tls_version_input
  }

  identity {
    type = var.identity_type_input
  }
}
