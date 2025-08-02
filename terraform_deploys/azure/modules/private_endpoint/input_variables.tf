variable "name_prefix_input" { type = string }
variable "private_dns_zone_group_name_input" { type = string }
variable "private_dns_zone_ids_input" { type = list(string) }
variable "subresource_names_input" { type = list(string) }
variable "private_service_connection_name_prefix_input" { type = string }
variable "location_input" { type = string }
variable "resource_group_name_input" { type = string }
variable "subnet_id_input" { type = string }
variable "private_endpoint_service_ids" {
  description = "List of resource IDs of servers to which we create private endpoints"
  type        = map(string)
}
