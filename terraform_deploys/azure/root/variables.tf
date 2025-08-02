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

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}
