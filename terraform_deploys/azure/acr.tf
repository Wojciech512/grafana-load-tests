/*
  Azure Container Registry (ACR) Terraform Resource:
  This configuration creates an Azure Container Registry (ACR) for storing and
  managing Docker container images and artifacts.

  Parameters:
    - name                : Name of the registry (variable: var.acr_name)
    - resource_group_name : Resource group for deployment (variable: var.resource_group_name)
    - location            : Azure region (variable: var.location)
    - sku                 : Registry SKU tier, e.g., Basic, Standard, Premium (variable: var.acr_sku)
    - admin_enabled       : Admin user access is disabled for security (set to false)

  Output:
    - acr_login_server    : The login server URL to use for pushing/pulling images

  Notes:
    - Admin user is disabled for better security.
    - Use managed identities or service principals for authentication.
    - The resource group must exist before creating the registry.
*/

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = false
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}
