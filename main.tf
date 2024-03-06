# Declare the use of the Azure Resource Manager provider
provider "azurerm" {
  features {}
}

# Create a new resource group, use declared variable values for name and location
resource "azurerm_resource_group" "rg1" {
    name     = var.rgname
    location = var.location
}

# Import the ServicePrincipalModule, pass the name from the declared variable value, wait for the resource group to be created
module "ServicePrincipal" {
  source                 = "./Modules/ServicePrincipal"
  service_principal_name = var.service_principal_name

  depends_on             = [ azurerm_resource_group.rg1 ]
}

resource "azurerm_role_assignment" "rolespn" {
  scope                = "/subscriptions/b38e5d20-9ac1-43eb-8531-c1d425068111"
  role_definition_name = "Contributor"
  principal_id         = module.ServicePrincipal.service_principal_object_id

  depends_on           = [ module.ServicePrincipal ]
}

module "KeyVault" {
  source                      = "./Modules/KeyVault"
  key_vault_name              = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.rgname
  service_principal_name      = module.ServicePrincipal.service_principal_name
  service_principal_object_id = module.ServicePrincipal.service_principal_object_id
  service_principal_tenant_id = module.ServicePrincipal.service_principal_tenant_id
}


resource "azurerm_role_assignment" "rolekv_user" {
  scope                = "/subscriptions/b38e5d20-9ac1-43eb-8531-c1d425068111/resourceGroups/${var.rgname}/providers/Microsoft.KeyVault/vaults/${var.key_vault_name}"
  role_definition_name = "Key Vault Administrator"
  principal_id         = "49b998a7-aa04-4db3-aaa7-426d9e2bfa92"

  depends_on = [ module.KeyVault ]
}

resource "azurerm_role_assignment" "rolekv_spn" {
  scope                = "/subscriptions/b38e5d20-9ac1-43eb-8531-c1d425068111/resourceGroups/${var.rgname}/providers/Microsoft.KeyVault/vaults/${var.key_vault_name}"
  role_definition_name = "Key Vault Administrator"
  principal_id         = module.ServicePrincipal.service_principal_object_id

  depends_on = [ module.KeyVault ]
}


resource "azurerm_key_vault_secret" "key_vault_secret" {
  name         = module.ServicePrincipal.client_id
  value        = module.ServicePrincipal.client_secret
  key_vault_id = module.KeyVault.key_vault_id

  depends_on   = [ 
    module.ServicePrincipal,
    azurerm_role_assignment.rolekv_spn,
    azurerm_role_assignment.rolekv_user
   ]
}

module "AppGateway" {
  source                  = "./Modules/AppGateway"

  virtual_network_name    = var.virtual_network_name
  location                = var.location
  resource_group_name     = var.rgname
  appgw_subnet_name       = var.appgw_subnet_name
  aks_subnet_name         = var.aks_subnet_name
  public_ip_name          = var.public_ip_name
  aks_subnet_pool         = var.aks_subnet_pool
  appgw_subnet_pool       = var.appgw_subnet_pool
  vnet_address_pool       = var.vnet_address_pool

  depends_on              = [ azurerm_resource_group.rg1 ]
}