variable "rgname" {
    type = string
    description = "resource group name"
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