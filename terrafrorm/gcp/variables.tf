variable "project_id" {
  type    = string
  default = "atlantean-yeti-454021-b3"
}

variable "repository_id" {
  type    = string
  default = "praca-magisterska-artifact-registry"
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

variable "GOOGLE_NAME" {
  type      = string
  sensitive = true
}

variable "GOOGLE_USER" {
  type      = string
  sensitive = true
}

variable "GOOGLE_PASSWORD" {
  type      = string
  sensitive = true
}

variable "GOOGLE_HOST" {
  type      = string
  sensitive = true
}

variable "GOOGLE_PORT" {
  type      = string
  sensitive = true
}

