# AWS conceptual equivalent: Service Control Policy
# Azure implementation: custom Azure Policy at Management Group scope
resource "azurerm_policy_definition" "allowed_locations" {
  name                = "allowed-kubernetes-lab-locations"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Restrict resource locations"
  management_group_id = var.management_group_id

  policy_rule = jsonencode({
    if = {
      allOf = [
        { field = "location", notIn = "[parameters('allowedLocations')]" },
        { field = "location", notEquals = "global" }
      ]
    }
    then = { effect = "deny" }
  })

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = { displayName = "Allowed locations" }
    }
  })
}

resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  display_name         = "Allow approved lab locations"
  management_group_id  = var.management_group_id
  policy_definition_id = azurerm_policy_definition.allowed_locations.id
  parameters = jsonencode({
    allowedLocations = { value = var.allowed_locations }
  })
}
