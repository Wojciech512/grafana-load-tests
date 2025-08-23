module "resource_group" {
  source = "../modules/resource_group"

  name_input = "praca-magisterska-proj-azure"
  # location_input = "Poland Central"
  location_input = "West Europe"
}

module "virtual_network" {
  source = "../modules/virtual_network"

  virtual_network_name_input = "app-postgress-virtual-network"
  address_space_input        = ["10.0.0.0/16"]

  resource_group_name_input     = module.resource_group.name_output
  resource_group_location_input = module.resource_group.location_output

  subnets_input = {
    app-subnet = {
      address_prefixes_input = ["10.0.4.0/23"]
      delegation_name_input  = "Microsoft.App.environments"
      service_name_input     = "Microsoft.App/environments"
      service_actions_input  = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
    database-subnet = {
      address_prefixes_input = ["10.0.1.0/24"]
      delegation_name_input  = "database-delegation"
      service_name_input     = "Microsoft.DBforPostgreSQL/flexibleServers"
      service_actions_input  = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
    private-endpoint-subnet = {
      address_prefixes_input = ["10.0.2.0/24"]
      delegation_name_input  = ""
      service_name_input     = ""
      service_actions_input  = []
    }
  }
}

module "container_registry" {
  source = "../modules/acr"

  random_string_input       = random_string.suffix.result
  name_input                = "acrwebapp"
  sku_input                 = "Standard"
  admin_enabled_input       = false
  resource_group_name_input = module.resource_group.name_output
  location_input            = module.resource_group.location_output
}

module "private_dns" {
  source                    = "../modules/dns"
  name_input                = "privatelink.postgres.database.azure.com"
  name_link_input           = "database-dns-link"
  resource_group_name_input = module.resource_group.name_output
  virtual_network_id_input  = module.virtual_network.vnet_id_output
}

# module "private_endpoint" {
#   source = "../modules/private_endpoint"
#
#   location_input    = module.resource_group.location_output
#   name_prefix_input = "database-private-endpoint"
#
#   private_endpoint_service_ids = {
#     db_b1ms = module.database.database_ids["database-b1ms-postgres"]
#     # db_b2s  = module.database.database_ids["database-b2s-postgres"]
#     # db_b2ms = module.database.database_ids["database-b2ms-postgres"]
#   }
#
#   private_service_connection_name_prefix_input = "database-private-service-connection"
#   resource_group_name_input                    = module.resource_group.name_output
#   subnet_id_input                              = module.virtual_network.subnet_ids_output["private-endpoint-subnet"]
#   subresource_names_input                      = ["postgresqlServer"]
#
#   private_dns_zone_group_name_input = "dns-group"
#   private_dns_zone_ids_input        = [module.private_dns.id_output]
# }

module "database" {
  source = "../modules/postgresql"

  random_string_input = random_string.suffix.result

  delegated_subnet_id_input = module.virtual_network.subnet_ids_output["database-subnet"]
  private_dns_zone_id_input = module.private_dns.id_output

  administrator_login_input           = var.AZURE_POSTGRESQL_USERNAME
  administrator_password_input        = var.AZURE_POSTGRESQL_PASSWORD
  resource_group_name_input           = module.resource_group.name_output
  location_input                      = module.resource_group.location_output
  backup_retention_days_input         = 7
  storage_mb_input                    = 32768
  version_input                       = "16"
  public_network_access_enabled_input = false
  geo_redundant_backup_enabled_input  = false

  databases_config_input = {
    database-b1ms-postgres = {
      sku_name_input = "B_Standard_B1ms"
    }
    # database-b2s-postgres = {
    #   sku_name_input = "B_Standard_B2s"
    # }
    # database-b2ms-postgres = {
    #   sku_name_input = "B_Standard_B2ms"
    # }
  }
}

module "firewall" {
  source = "../modules/firewall"

  firewall_rule_config_input = {}
}

module "container_app" {
  source = "../modules/container_app"

  docker_image_name_input   = "ecommerce-app:latest"
  docker_registry_url_input = module.container_registry.login_server
  app_port_input            = var.APP_PORT
  acr_registry_id_input     = module.container_registry.id
  location_input            = module.resource_group.location_output
  random_string_input       = random_string.suffix.result
  resource_group_name_input = module.resource_group.name_output
  subnet_id_input           = module.virtual_network.subnet_ids_output["app-subnet"]

  plan_profiles_input = {
    low = {
      cpu_input           = 1.0,
      memory_input        = "2.0Gi",
      database_host_input = module.database.database_names["database-b1ms-postgres"]
    },
    # medium = {
    #   cpu_input           = 2.0,
    #   memory_input        = "4.0Gi",
    #   database_host_input = module.database.database_names["database-b2s-postgres"]
    # },
    # high = {
    #   cpu_input           = 3.0,
    #   memory_input        = "6.0Gi",
    #   database_host_input = module.database.database_names["database-b2ms-postgres"]
    # }
  }

  common_app_settings_input = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"

    "AZURE_POSTGRESQL_NAME"     = var.AZURE_POSTGRESQL_NAME
    "AZURE_POSTGRESQL_USERNAME" = var.AZURE_POSTGRESQL_USERNAME
    "AZURE_POSTGRESQL_PASSWORD" = var.AZURE_POSTGRESQL_PASSWORD
    "AZURE_POSTGRESQL_PORT"     = var.AZURE_POSTGRESQL_PORT

    "DEBUG"                = var.DEBUG
    "ALLOWED_HOSTS"        = var.ALLOWED_HOSTS
    "SECRET_KEY"           = var.SECRET_KEY
    "EMAIL_HOST_USER"      = var.EMAIL_HOST_USER
    "EMAIL_HOST_PASSWORD"  = var.EMAIL_HOST_PASSWORD
    "CSRF_TRUSTED_ORIGINS" = var.CSRF_TRUSTED_ORIGINS
  }
}

# module "service_plan" {
#   source = "../modules/service_plan"
#
#   random_string_input = random_string.suffix.result
#
#   service_plan_config_input = {
#     web-app-plan-b1-linux = {
#       location_resource_group_input = module.resource_group.location_output
#       resource_group_name_input     = module.resource_group.name_output
#       os_type_input                 = "Linux"
#       sku_name_input                = "B1"
#     }
#
#     web-app-plan-b2-linux = {
#       location_resource_group_input = module.resource_group.location_output
#       resource_group_name_input     = module.resource_group.name_output
#       os_type_input                 = "Linux"
#       sku_name_input                = "B2"
#     }
#
#     web-app-plan-b3-linux = {
#       location_resource_group_input = module.resource_group.location_output
#       resource_group_name_input     = module.resource_group.name_output
#       os_type_input                 = "Linux"
#       sku_name_input                = "B3"
#     }
#   }
# }

# module "web_app" {
#   source = "../modules/web_app"
#
#   docker_image_name_input   = "ecommerce-app:latest"
#   docker_registry_url_input = "https://${module.container_registry.login_server}"
#   acr_registry_id_input     = module.container_registry.id
#   location_input            = module.resource_group.location_output
#   resource_group_name_input = module.resource_group.name_output
#   subnet_id_input           = module.virtual_network.subnet_ids["app-subnet"]
#
#   random_string_input = random_string.suffix.result
#
#
#   web_app_config_input = {
#     web-app-b1-linux = {
#       service_plan_id_input = module.service_plan.service_plan_ids["web-app-plan-b1-linux"]
#       database_host_input   = module.database.database_names["database-b1ms-postgres"]
#     }
#
#     web-app-b2-linux = {
#       service_plan_id_input = module.service_plan.service_plan_ids["web-app-plan-b2-linux"]
#       database_host_input   = module.database.database_names["database-b2s-postgres"]
#     }
#
#     web-app-b3-linux = {
#       service_plan_id_input = module.service_plan.service_plan_ids["web-app-plan-b3-linux"]
#       database_host_input   = module.database.database_names["database-b2ms-postgres"]
#     }
#   }
#
#   common_app_settings_input = {
#     "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
#     "PORT"                                = var.APP_PORT
#     "WEBSITES_PORT"                       = var.APP_PORT
#
#     "AZURE_POSTGRESQL_NAME"     = var.AZURE_POSTGRESQL_NAME
#     "AZURE_POSTGRESQL_USERNAME" = var.AZURE_POSTGRESQL_USERNAME
#     "AZURE_POSTGRESQL_PASSWORD" = var.AZURE_POSTGRESQL_PASSWORD
#     "AZURE_POSTGRESQL_PORT"     = var.AZURE_POSTGRESQL_PORT
#
#     "DEBUG"                = var.DEBUG
#     "ALLOWED_HOSTS"        = var.ALLOWED_HOSTS
#     "SECRET_KEY"           = var.SECRET_KEY
#     "EMAIL_HOST_USER"      = var.EMAIL_HOST_USER
#     "EMAIL_HOST_PASSWORD"  = var.EMAIL_HOST_PASSWORD
#     "CSRF_TRUSTED_ORIGINS" = var.CSRF_TRUSTED_ORIGINS
#   }
# }

