resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_container_registry" "this" {
  name                          = replace(lower("${var.name}acr"), "-", "")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
  zone_redundancy_enabled       = true
  tags                          = var.tags
}

resource "azurerm_kubernetes_cluster" "this" {
  name                              = var.name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = var.dns_prefix
  kubernetes_version                = var.kubernetes_version
  private_cluster_enabled           = true
  private_dns_zone_id               = "System"
  local_account_disabled            = true
  role_based_access_control_enabled = true

  default_node_pool {
    name                 = "system"
    vm_size              = var.node_vm_size
    vnet_subnet_id       = var.subnet_id
    auto_scaling_enabled = true
    min_count            = var.node_min_count
    max_count            = var.node_max_count
    os_disk_size_gb      = var.node_os_disk_size_gb
    type                 = "VirtualMachineScaleSets"
    node_labels          = { pool = "system" }
    upgrade_settings { max_surge = "33%" }
  }

  identity { type = "SystemAssigned" }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  oms_agent { log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id }
  key_vault_secrets_provider { secret_rotation_enabled = true }

  workload_identity_enabled    = true
  oidc_issuer_enabled          = true
  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 48
  tags                         = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
