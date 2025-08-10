output "container_app_ids" {
  description = "Map of web app IDs"
  value = {
    for name, source in azurerm_container_app.this :
    name => source.id
  }
}

output "container_env_id" {
  value = azurerm_container_app_environment.this.id
}
