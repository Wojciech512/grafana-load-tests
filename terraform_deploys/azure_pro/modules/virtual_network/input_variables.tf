variable "virtual_network_name_input" {
  description = "Name of the virtual network"
  type        = string
}

variable "resource_group_name_input" {
  description = "Name of the resource group in which to create the VNet"
  type        = string
}
variable "resource_group_location_input" {
  description = "Azure region"
  type        = string
}

variable "address_space_input" {
  description = "Address space for the VNet"
  type        = list(string)
}

variable "dns_servers_input" {
  description = "List of DNS servers"
  type        = list(string)
}

variable "subnets_input" {
  description = "Map of subnets to create"
  type = map(object({
    address_prefixes_input = list(string)
    delegation_name_input  = string
    service_name_input     = string
    service_actions_input  = list(string)
  }))
}
