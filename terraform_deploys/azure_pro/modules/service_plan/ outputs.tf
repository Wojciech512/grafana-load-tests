output "service_plan_ids" {
  value = {
    for name, source in azurerm_service_plan.this :
    name => source.id
  }
}


