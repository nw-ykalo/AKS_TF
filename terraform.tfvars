prod_azure_subscription = ""
prod_aks_admin_group_id = ""
dev_azure_subscription = ""
dev_aks_admin_group_id = ""


admin_group_name         = "AKS_Admins"

# Resource group and location
rgname                   = "AKS_Deployment_RG"
location                 = "West US 2"

# ServicePrincipal
service_principal_name   = "AKS_Deployment_SPN"

# KeyVault
key_vault_name           = "AKS-Key-Vault-ykal"

# NATGW
nat_name                 = "aks_natgw"
nat_pip_name             = "aks_natgw_pip"

# AppGW
virtual_network_name     = "AKS_VNet"
aks_subnet_name          = "AKS_Subnet"
appgw_subnet_name        = "AppGW_Subnet"
public_ip_name           = "AppGW_PIP"
aks_subnet_pool          = "10.10.1.0/24"
appgw_subnet_pool        = "10.10.254.0/24"
vnet_address_pool        = "10.10.0.0/16"

# LogAnalytics
la_workspace_name        = "aks-loganalytics-ykal"

# AKS
cluster_name             = "test-aks-cluster"
kubernetes_version       = "1.29"
vm_size                  = "Standard_A2_v2"
node_count               = 5
aks_dns_service_ip       = "10.240.0.53"
aks_service_cidr         = "10.240.0.0/12"
