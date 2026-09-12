provider "azurerm" {
  features {}
  tenant_id       = var.tenant_id
  subscription_id = var.management_subscription_id
}

module "hierarchy" {
  source                     = "../../modules/management-groups"
  management_group_name      = var.management_group_name
  lab_subscription_id        = var.lab_subscription_id
  production_subscription_id = var.production_subscription_id
}

module "policy" {
  source              = "../../modules/policy"
  management_group_id = module.hierarchy.management_group_id
  allowed_locations   = var.allowed_locations
}
