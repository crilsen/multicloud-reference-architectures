# AWS conceptual equivalent: Organizational Unit in AWS Organizations
# Azure implementation: Management Group
resource "azurerm_management_group" "workloads" {
  name         = var.management_group_name
  display_name = "Kubernetes Lab Workloads"
}

# AWS conceptual equivalent: attaching member accounts to an Organizational Unit
# Azure implementation: Management Group Subscription Association
resource "azurerm_management_group_subscription_association" "lab" {
  management_group_id = azurerm_management_group.workloads.id
  subscription_id     = "/subscriptions/${var.lab_subscription_id}"
}

resource "azurerm_management_group_subscription_association" "production" {
  management_group_id = azurerm_management_group.workloads.id
  subscription_id     = "/subscriptions/${var.production_subscription_id}"
}
