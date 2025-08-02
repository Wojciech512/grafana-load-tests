variable "databases_config_input" {
  type = map(object({
    sku_name_input = string
  }))
}
variable "random_string_input" { type = string }
variable "resource_group_name_input" { type = string }
variable "location_input" { type = string }
variable "administrator_login_input" { type = string }
variable "administrator_password_input" { type = string }
variable "version_input" { type = string }
variable "storage_mb_input" { type = number }
variable "backup_retention_days_input" { type = number }
variable "geo_redundant_backup_enabled_input" { type = bool }
variable "public_network_access_enabled_input" { type = bool }
