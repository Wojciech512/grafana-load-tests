variable "resource_group_name" {
  type    = string
  default = "praca-magisterska-proj-azure"
}

variable "location" {
  type    = string
  default = "Poland Central"
}

variable "AZURE_POSTGRESQL_NAME" {
  type      = string
  sensitive = true
}

variable "AZURE_POSTGRESQL_USERNAME" {
  type      = string
  sensitive = true
}

variable "AZURE_POSTGRESQL_PASSWORD" {
  type      = string
  sensitive = true
}

variable "acr_name" {
  type    = string
  default = "pracamagisterskaacr"
}

variable "acr_sku" {
  type    = string
  default = "Standard"
}

variable "DEBUG" {
  type      = string
  sensitive = true
}

variable "ALLOWED_HOSTS" {
  type      = string
  sensitive = true
}

variable "SECRET_KEY" {
  type      = string
  sensitive = true
}

variable "EMAIL_HOST_USER" {
  type      = string
  sensitive = true
}

variable "EMAIL_HOST_PASSWORD" {
  type      = string
  sensitive = true
}

variable "CSRF_TRUSTED_ORIGINS" {
  type      = string
  sensitive = true
}

variable "PORT" {
  type    = string
  default = "8000"
}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}
