variable "location" {
  type    = string
  default = "polandcentral"
}

variable "resource_group_name" {
  type    = string
  default = "rg-terraform-app-db"
}

variable "container_image" {
  type    = string
  default = "nginx:latest"
}

variable "PROXY_DB_USERNAME" {
  type      = string
  sensitive = true
}

variable "PROXY_DB_PASSWORD" {
  type      = string
  sensitive = true
}

variable "SP_NAME" {
  type      = string
  sensitive = true
}

variable "SP_PASSWORD" {
  type      = string
  sensitive = true
}

variable "DEBUG" {
  type = bool
}

variable "ALLOWED_HOSTS" {
  type = string
}

variable "EMAIL_HOST_USER" {
  type      = string
  sensitive = true
}

variable "EMAIL_HOST_PASSWORD" {
  type      = string
  sensitive = true
}

variable "SECRET_KEY" {
  type      = string
  sensitive = true
}

variable "CSRF_TRUSTED_ORIGINS" {
  type      = string
  sensitive = true
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

