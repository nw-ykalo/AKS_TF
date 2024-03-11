# Declare the use of the Azure Resource Manager provider
provider "azurerm" {
  features {}
}
provider "azuread" {
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

resource "azuread_group" "admin_group"{
  display_name = var.admin_group_name
  security_enabled = true
  owners = [ "49b998a7-aa04-4db3-aaa7-426d9e2bfa92" ]
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


resource "azurerm_role_assignment" "rolekv_group" {
  scope                = "/subscriptions/b38e5d20-9ac1-43eb-8531-c1d425068111/resourceGroups/${var.rgname}/providers/Microsoft.KeyVault/vaults/${var.key_vault_name}"
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_group.admin_group.id

  depends_on = [ module.KeyVault,azuread_group.admin_group ]
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

module NATGateway {
  source = "./Modules/NATGateway"

  location = var.location
  resource_group_name = var.rgname
  pip_name = var.nat_pip_name
  nat_name = var.nat_name
}

module "AppGateway" {
  source                  = "./Modules/AppGateway"

  appgw_name              = var.appgw_name
  virtual_network_name    = var.virtual_network_name
  location                = var.location
  resource_group_name     = var.rgname
  appgw_subnet_name       = var.appgw_subnet_name
  aks_subnet_name         = var.aks_subnet_name
  public_ip_name          = var.public_ip_name
  aks_subnet_pool         = var.aks_subnet_pool
  appgw_subnet_pool       = var.appgw_subnet_pool
  vnet_address_pool       = var.vnet_address_pool
  nat_gateway_id          = module.NATGateway.nat_gateway_id

  depends_on              = [ azurerm_resource_group.rg1,module.NATGateway ]
}

module "LogAnalytics" {
  source                = "./Modules/LogAnalytics"

  la_workspace_name     = var.la_workspace_name
  location              = var.location
  resource_group_name   = var.rgname
}

module "AKS" {
  source                  = "./Modules/AKS"
  depends_on              = [ module.AppGateway,module.LogAnalytics,module.NATGateway ]

  cluster_name            = var.cluster_name
  kubernetes_version      = var.kubernetes_version
  admin_group_object_id   = azuread_group.admin_group.id
  vm_size                 = var.vm_size
  node_count              = var.node_count
  resource_group_name     = var.rgname
  location                = var.location
  la_workspace_id         = module.LogAnalytics.la_workspace_id
  appgw_aks_subnet        = module.AppGateway.aks_subnet_id
  appgw_gw_subnet         = module.AppGateway.appgw_subnet_id
  appgw_gw_id             = module.AppGateway.appgw_id
  dns_service_ip          = var.aks_dns_service_ip
  service_cidr            = var.aks_service_cidr
  nat_gateway_id          = module.NATGateway.nat_gateway_id
}

# Add required permissions for the AGIC client ID
# Contributer on the AppGW
resource "azurerm_role_assignment" "appgw_agic_role" {
  scope                = module.AppGateway.appgw_id
  role_definition_name = "Contributor"
  principal_id         = module.AKS.agic_client_id

  depends_on = [ module.AKS,module.AppGateway ]
}
# Reader on the Resource Group
resource "azurerm_role_assignment" "resourcegroup_agic_role" {
  scope                = azurerm_resource_group.rg1.id
  role_definition_name = "Reader"
  principal_id         = module.AKS.agic_client_id

  depends_on = [ module.AKS,module.AppGateway ]
}
# Contributor on the VNet
resource "azurerm_role_assignment" "vnet_agic_role" {
  scope                = module.AppGateway.aks_vnet_id
  role_definition_name = "Contributor"
  principal_id         = module.AKS.agic_client_id

  depends_on = [ module.AKS,module.AppGateway ]
}
# VNet Conrtibutor for AKS cluster principal ID
resource "azurerm_role_assignment" "vnet_k8s_role" {
  scope                = module.AppGateway.aks_vnet_id
  role_definition_name = "Contributor"
  principal_id         = module.AKS.aks_cluster_principal_id

  depends_on = [ module.AKS,module.AppGateway ]
}
