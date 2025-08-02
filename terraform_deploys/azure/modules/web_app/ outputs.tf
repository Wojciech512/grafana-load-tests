output "web_app_ids" {
  description = "Map of web app IDs"
  value = {
    for name, source in azurerm_linux_web_app.this :
    name => source.id
  }
}
