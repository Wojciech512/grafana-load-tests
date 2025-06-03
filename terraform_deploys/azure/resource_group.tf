provider "azurerm" {
  features {}
  subscription_id = "0eb4c771-2ce9-49b9-92cd-dbf485cc76e7"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
