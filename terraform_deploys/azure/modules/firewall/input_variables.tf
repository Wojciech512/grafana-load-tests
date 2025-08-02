variable "firewall_rule_config_input" {
  type = map(object({
    end_ip_address_input   = string
    name_input             = string
    server_id_input        = string
    start_ip_address_input = string
  }))
}