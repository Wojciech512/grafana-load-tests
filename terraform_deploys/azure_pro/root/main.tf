module "resource_group" {
  source   = "../modules/resource_group"
  name     = var.resource_group_name
  location = var.resource_group_location
}
