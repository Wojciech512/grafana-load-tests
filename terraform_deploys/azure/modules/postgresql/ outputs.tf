output "database_ids" {
  description = "Map of database IDs"
  value = {
    for name, source in azurerm_postgresql_flexible_server.this :
    name => source.id
  }
}

output "database_names_output" {
  description = "Map of PostgreSQL flexible server names"
  value = {
    for name, source in azurerm_postgresql_flexible_server.this :
    name => source.name
  }
}

output "server_fqdns_output" {
  description = "Map of PostgreSQL flexible server FQDNs"
  value = {
    for name, source in azurerm_postgresql_flexible_server.this :
    name => source.fqdn
  }
}
