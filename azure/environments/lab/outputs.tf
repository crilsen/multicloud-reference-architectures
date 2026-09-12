output "resource_group_name" { value = azurerm_resource_group.this.name }
output "aks_cluster_name" { value = module.aks.cluster_name }
output "aks_private_fqdn" { value = module.aks.private_fqdn }
output "acr_login_server" { value = module.aks.registry_login_server }
output "oidc_issuer_url" { value = module.aks.oidc_issuer_url }
