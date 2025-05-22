variable "project_id" {
  type    = string
  default = "praca-magisterska-proj-gcp-6"
}

variable "project_region" {
  type    = string
  default = "europe-central2"
}

variable "project_name" {
  type    = string
  default = "praca-magisterska-projekt-gcp"
}

variable "repository_id" {
  type    = string
  default = "praca-magisterska-artifact-registry"
}

variable "billing_account" {
  type    = string
  default = "015886-0592BC-AB7956"
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
