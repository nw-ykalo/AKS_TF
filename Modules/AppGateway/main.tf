resource "azurerm_virtual_network" "AKS_VNet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.vnet_address_pool]
}

resource "azurerm_subnet" "AppGW_Subnet" {
  name                 = var.appgw_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.appgw_subnet_pool]
  depends_on = [ azurerm_virtual_network.AKS_VNet ]
}

resource "azurerm_subnet" "AKS_Subnet" {
  name                 = var.aks_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.aks_subnet_pool]
  depends_on = [ azurerm_virtual_network.AKS_VNet ]
}

resource "azurerm_subnet_nat_gateway_association" "example" {
  subnet_id      = azurerm_subnet.AKS_Subnet.id
  nat_gateway_id = var.nat_gateway_id
}

resource "azurerm_public_ip" "AppGW_PIP" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}


# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.AKS_VNet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.AKS_VNet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.AKS_VNet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.AKS_VNet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.AKS_VNet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.AKS_VNet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.AKS_VNet.name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  depends_on          = [ azurerm_public_ip.AppGW_PIP,azurerm_subnet.AppGW_Subnet ]
  name                = "AKS_AppGW"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.AppGW_Subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.AppGW_PIP.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
