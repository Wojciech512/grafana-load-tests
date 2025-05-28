output "service_principal_credentials" {
  value = {
    client_id     = azuread_service_principal.prom.application_id
    client_secret = azuread_service_principal_password.prom.value
    tenant_id     = data.azurerm_client_config.current.tenant_id
  }
  sensitive = true
}

output "app_b1_hostname" {
  value = azurerm_app_service.b1.default_site_hostname
}

output "db_b1_fqdn" {
  value = azurerm_postgresql_flexible_server.b1.fqdn
}

# analogicznie możesz dodać outputy dla B2 i B3
