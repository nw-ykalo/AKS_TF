variable prod_azure_subscription {
    type = string
}
variable prod_aks_admin_group_id {
    type = string
}
variable dev_azure_subscription {
    type = string
}
variable dev_aks_admin_group_id {
    type = string
}

variable "rgname" {
    type = string
    description = "resource group name"
}

variable "admin_group_name" {
    type = string
    description = "Azure AD group to hold AKS deployment admins"
}

variable "location" {
    type = string
    default = "West US 2"
}

variable "service_principal_name" {
    type = string
}

variable key_vault_name {
    type = string
}

variable virtual_network_name {
    type = string
}

variable aks_subnet_name {
    type = string
}

variable appgw_name {
    type = string
}

variable appgw_subnet_name {
    type = string
}

variable public_ip_name {
    type = string
}

variable aks_subnet_pool {
    type = string
}

variable appgw_subnet_pool {
    type = string
}

variable vnet_address_pool {
    type = string
}

variable la_workspace_name {
    type = string
}

variable cluster_name {
    type = string
}

variable node_count {
}

variable kubernetes_version {
}

variable vm_size {
}

variable nat_name {
    type = string
}

variable nat_pip_name {
    type = string
}

variable aks_dns_service_ip {
    type = string
}

variable aks_service_cidr {
    type = string
}