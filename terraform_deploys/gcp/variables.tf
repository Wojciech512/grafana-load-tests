variable "project_id" {
  type    = string
  default = "atlantean-yeti-454021-b3"
}

variable "project_name" {
  type    = string
  default = "praca magisterska projekt"
}

variable "repository_id" {
  type    = string
  default = "praca-magisterska-artifact-registry"
}

variable "db_id" {
  type    = string
  default = "praca-magisterska-db"
}

variable "region" {
  type    = string
  default = "europe-central2"
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

variable "GOOGLE_POSTGRESQL_NAME" {
  type      = string
  sensitive = true
}

variable "GOOGLE_POSTGRESQL_USERNAME" {
  type      = string
  sensitive = true
}

variable "GOOGLE_POSTGRESQL_PASSWORD" {
  type      = string
  sensitive = true
}

variable "GOOGLE_POSTGRESQL_HOST" {
  type      = string
  sensitive = true
}

variable "GOOGLE_POSTGRESQL_PORT" {
  type      = string
  sensitive = true
}

