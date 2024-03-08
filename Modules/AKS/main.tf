resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.cluster_name}aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.cluster_name}dns"
  kubernetes_version  = var.kubernetes_version
 
  node_resource_group = "${var.cluster_name}-node-rg"
 
  default_node_pool {
    name                 = "agentpool"
    node_count           = var.node_count
    vm_size              = var.vm_size
    vnet_subnet_id       = var.appgw_aks_subnet
    type                 = "VirtualMachineScaleSets"
    orchestrator_version = var.kubernetes_version
    # os_disk_type = "value"
    # os_disk_size_gb = 0
  }

 
  identity {
    type = "SystemAssigned"
  }
 
  oms_agent {
      log_analytics_workspace_id = var.la_workspace_id
  }
 
  ingress_application_gateway {
      gateway_id = var.appgw_gw_id
  }
 
 
  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
    dns_service_ip    = var.dns_service_ip
    service_cidr      = var.service_cidr
    outbound_type     = "userAssignedNATGateway"
  }
 
  azure_active_directory_role_based_access_control {
    managed = true
    admin_group_object_ids = [var.admin_group_object_id]
    azure_rbac_enabled = true
  }
 
}
 
data "azurerm_resource_group" "node_resource_group" {
  name = azurerm_kubernetes_cluster.k8s.node_resource_group
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}
 
resource "azurerm_role_assignment" "node_infrastructure_update_scale_set" {
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.node_resource_group.id
  role_definition_name = "Virtual Machine Contributor"
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}