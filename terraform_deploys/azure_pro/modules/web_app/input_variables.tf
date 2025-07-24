variable "random_string_input" {
  description = "Random suffix for naming Web Apps"
  type        = string
}

variable "identity_type_input" {
  description = "Random suffix for naming Web Apps"
  type        = string
  default     = "SystemAssigned"
}

variable "resource_group_name_input" {
  description = "Name of the resource group where Web Apps will be deployed"
  type        = string
}

variable "location_input" {
  description = "Azure region for the Web Apps"
  type        = string
}

variable "docker_image_name_input" {
  description = "Name and tag of the Docker image to deploy"
  type        = string
}

variable "docker_registry_url_input" {
  description = "URL of the container registry (e.g. https://myregistry.azurecr.io)"
  type        = string
}

variable "acr_registry_id_input" {
  description = "Resource ID of the Azure Container Registry for ACR pull managed identity"
  type        = string
}

variable "subnet_id_input" {
  description = "Resource ID of the Azure Container Registry for ACR pull managed identity"
  type        = string
}

variable "http2_enabled_input" {
  description = "Enable HTTP/2 support"
  type        = bool
  default     = true
}

variable "container_registry_use_managed_identity_input" {
  description = "Enable managed identity"
  type        = bool
  default     = true
}

variable "minimum_tls_version_input" {
  description = "Minimum TLS version enforced for the Web Apps"
  type        = string
  default     = "1.2"
}

variable "https_only_input" {
  description = "Require HTTPS only"
  type        = bool
  default     = false
}

variable "vnet_route_all_enabled_input" {
  description = "Enable Route All for VNet integration"
  type        = bool
  default     = false
}

variable "role_definition_name_input" {
  description = "Role definition name"
  type        = string
  default     = "AcrPull"
}

variable "common_app_settings_input" {
  description = "Common App Settings (environment variables)"
  type        = map(string)
}

variable "web_app_config_input" {
  description = "Map of service plan IDs keyed by Web App instance name"
  type = map(object({
    service_plan_id_input = string
    database_host_input   = string
  }))
}
