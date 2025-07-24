output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  description = "Map of subnet IDs"
  value = {
    for k, s in azurerm_subnet.this :
    k => s.id
  }
}
