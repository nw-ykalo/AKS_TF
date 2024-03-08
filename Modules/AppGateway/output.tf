output aks_vnet_id {
    value = azurerm_virtual_network.AKS_VNet.id
}

output aks_subnet_id {
    value = azurerm_subnet.AKS_Subnet.id
}

output appgw_subnet_id {
    value = azurerm_subnet.AppGW_Subnet.id
}

output public_ip_address {
    value = azurerm_public_ip.AppGW_PIP.ip_address
}

output public_ip_id {
    value = azurerm_public_ip.AppGW_PIP.id
}

output appgw_id {
    value = azurerm_application_gateway.network.id
}