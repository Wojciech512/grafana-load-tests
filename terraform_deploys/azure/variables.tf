variable "resource_group_name" {
  type    = string
  default = "praca-magisterska-proj-azure-2"
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
