output "firewall_ids" {
  value = {
    for name, source in azurerm_postgresql_flexible_server_firewall_rule.this :
    name => source.id
  }
}