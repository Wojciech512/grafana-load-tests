variable "service_plan_config_input" {
  type = map(object({
    location_resource_group_input = string
    resource_group_name_input     = string
    os_type_input                 = string
    sku_name_input                = string
  }))
}

variable "random_string_input" {
  type = string
}

