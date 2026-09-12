resource "azurerm_resource_group" "this" {
  name     = "rg-${var.project_name}-lab"
  location = var.azure_location
  tags     = local.tags
}

locals {
  tags = merge(var.tags, { environment = "lab", managed-by = "terraform" })
}

module "network" {
  source                            = "../../modules/network"
  name                              = var.project_name
  location                          = azurerm_resource_group.this.location
  resource_group_name               = azurerm_resource_group.this.name
  address_space                     = [var.vnet_cidr]
  aks_subnet_prefixes               = var.aks_subnet_prefixes
  private_endpoints_subnet_prefixes = var.private_endpoints_subnet_prefixes
  tags                              = local.tags
}

module "aks" {
  source                 = "../../modules/aks"
  name                   = "${var.project_name}-aks"
  location               = azurerm_resource_group.this.location
  resource_group_name    = azurerm_resource_group.this.name
  dns_prefix             = var.project_name
  kubernetes_version     = var.kubernetes_version
  subnet_id              = module.network.aks_subnet_id
  node_vm_size           = var.node_vm_size
  node_min_count         = var.node_min_count
  node_max_count         = var.node_max_count
  node_os_disk_size_gb   = var.node_os_disk_size_gb
  admin_group_object_ids = var.admin_group_object_ids
  tags                   = local.tags
}
