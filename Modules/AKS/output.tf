output agic_client_id {
  value = azurerm_kubernetes_cluster.k8s.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

output aks_cluster_principal_id {
    value = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
}