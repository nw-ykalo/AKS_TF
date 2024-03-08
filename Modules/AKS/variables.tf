variable "resource_group_name" {
    type = string
    default = "AKS_Deployment_RG"
}

variable "location" {
    type = string
}

variable "cluster_name" {
    type = string
}

variable "kubernetes_version" {
    type = string
}

variable "node_count" {
}

variable "vm_size" {
}

variable "admin_group_object_id" {
    type = string
}

variable "la_workspace_id" {
    type = string
}

variable "appgw_aks_subnet" {
    type = string
}

variable "appgw_gw_subnet" {
    type = string
}

variable "appgw_gw_id" {
    type = string
}

variable "nat_gateway_id" {
    type = string
}

variable dns_service_ip {
    type = string
}

variable service_cidr {
    type = string
}