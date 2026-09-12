output "account_structure" {
  value = {
    management_tenant       = var.tenant_id
    lab_subscription        = var.lab_subscription_id
    production_subscription = var.production_subscription_id
  }
  sensitive = true
}
output "management_group_id" { value = module.hierarchy.management_group_id }
