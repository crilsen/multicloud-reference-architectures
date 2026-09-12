azure_location                    = "eastus"
project_name                      = "kubernetes-lab"
kubernetes_version                = "1.34"
vnet_cidr                         = "10.52.0.0/16"
aks_subnet_prefixes               = ["10.52.0.0/20"]
private_endpoints_subnet_prefixes = ["10.52.16.0/24"]
node_vm_size                      = "Standard_D4s_v7"
node_min_count                    = 1
node_max_count                    = 3
node_os_disk_size_gb              = 128
admin_group_object_ids            = []
tags = {
  project = "multicloud-reference-architectures"
  owner   = "platform"
}
