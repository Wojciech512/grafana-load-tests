variable "DEBUG" { sensitive = true }
variable "APP_PORT" { sensitive = true }
variable "SECRET_KEY" { sensitive = true }
variable "ALLOWED_HOSTS" { sensitive = true }
variable "EMAIL_HOST_USER" { sensitive = true }
variable "EMAIL_HOST_PASSWORD" { sensitive = true }
variable "CSRF_TRUSTED_ORIGINS" { sensitive = true }

variable "AZURE_POSTGRESQL_PORT" { sensitive = true }
variable "AZURE_POSTGRESQL_NAME" { sensitive = true }
variable "AZURE_POSTGRESQL_PASSWORD" { sensitive = true }
variable "AZURE_POSTGRESQL_USERNAME" { sensitive = true }

variable "AZURE_SUBSCRIPTION_ID_POLSL" { sensitive = true }
variable "AZURE_SUBSCRIPTION_ID_PRIVATE" { sensitive = true }

variable "resource_group_name" {
  description = "Istniejąca grupa zasobów w Azure"
  type        = string
}

variable "location" {
  description = "Region Azure (np. westeurope)"
  type        = string
}

variable "acr_login_server" {
  description = "Login server ACR (np. myregistry.azurecr.io)"
  type        = string
}

variable "acr_id" {
  description = "Pełny Resource ID ACR (do przypisania roli AcrPull)"
  type        = string
}

variable "container_image" {
  description = "Pełna nazwa obrazu (np. myregistry.azurecr.io/app:latest)"
  type        = string
}

variable "app_port" {
  description = "Port aplikacji w kontenerze"
  type        = number
  default     = 8080
}

variable "db_admin_user" {
  description = "Login administratora PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_admin_password" {
  description = "Hasło administratora PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nazwa bazy danych do utworzenia"
  type        = string
  default     = "appdb"
}

variable "db_version" {
  description = "Wersja PostgreSQL Flexible Server"
  type        = string
  default     = "16"
}

variable "env_vars" {
  description = "Dodatkowe zmienne środowiskowe dla aplikacji (mapa name=>value)"
  type        = map(string)
  default     = {}
}
