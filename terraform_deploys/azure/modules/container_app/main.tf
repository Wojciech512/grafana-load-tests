resource "azurerm_container_app" "this" {
  for_each = var.plan_profiles_input

  name                         = "${each.key}-${var.random_string_input}"
  resource_group_name          = var.resource_group_name_input
  container_app_environment_id = azurerm_container_app_environment.this.id
  revision_mode                = "Single"

  identity {
    type = var.identity_type_input
  }

  registry {
    server   = var.docker_registry_url_input
    identity = "System"
  }

  ingress {
    external_enabled           = true
    target_port                = tonumber(var.app_port_input)
    allow_insecure_connections = false

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = 0
    max_replicas = 1

    container {
      name   = each.key
      image  = "${var.docker_registry_url_input}/${var.docker_image_name_input}"
      cpu    = each.value.cpu_input
      memory = each.value.memory_input

      env {
        name  = "PORT"
        value = var.app_port_input
      }
      env {
        name  = "WEBSITES_PORT"
        value = var.app_port_input
      }
      env {
        name  = "AZURE_POSTGRESQL_HOST"
        value = "${each.value.database_host_input}.privatelink.postgres.database.azure.com"
      }

      dynamic "env" {
        for_each = var.common_app_settings_input
        content {
          name  = env.key
          value = env.value
        }
      }


    }
  }
}

resource "azurerm_container_app_environment" "this" {
  name                = "containerAppEnvironment"
  location            = var.location_input
  resource_group_name = var.resource_group_name_input

  infrastructure_subnet_id       = var.subnet_id_input
  internal_load_balancer_enabled = false

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }

  timeouts {
    create = "180m"
    update = "180m"
  }
}
