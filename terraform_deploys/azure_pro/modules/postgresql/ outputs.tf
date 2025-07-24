output "database_ids" {
  description = "Map of database IDs"
  value = {
    for name, source in azurerm_postgresql_flexible_server.this :
    name => source.id
  }
}

output "database_names" {
  description = "Map of database names"
  value = {
    for name, source in azurerm_postgresql_flexible_server.this :
    name => source.name
  }
}
