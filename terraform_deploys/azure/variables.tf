variable "resource_group_name" {
  description = "Nazwa Resource Group w Azure"
  type        = string
  default     = "praca-magisterska-proj-azure-1"
}

variable "location" {
  description = "Region (lokalizacja) w Azure, w którym będą tworzone zasoby"
  type        = string
  default     = "Poland Central"
}

variable "AZURE_POSTGRESQL_NAME" {
  description = "Prefiks nazwy dla instancji PostgreSQL"
  type        = string
  sensitive   = true

}

variable "AZURE_POSTGRESQL_USERNAME" {
  description = "Administator (login) dla PostgreSQL"
  type        = string
  sensitive   = true

}

variable "AZURE_POSTGRESQL_PASSWORD" {
  description = "Hasło administratora PostgreSQL"
  type        = string
  sensitive   = true
}

variable "acr_name" {
  description = "Nazwa Azure Container Registry (musi być unikalna w całym Azure)"
  type        = string
  default     = "pracamagisterskaacr"
}

variable "acr_sku" {
  description = "SKU ACR: Basic, Standard lub Premium"
  type        = string
  default     = "Standard"
}
