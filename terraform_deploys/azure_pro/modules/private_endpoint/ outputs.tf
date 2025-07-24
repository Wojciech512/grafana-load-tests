output "private_endpoint_ids" {
  description = "Map of private endpoint IDs"
  value = { for name, source in azurerm_private_endpoint.this :
  name => source.id }
}
