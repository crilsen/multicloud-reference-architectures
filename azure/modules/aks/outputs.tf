output "cluster_name" { value = azurerm_kubernetes_cluster.this.name }
output "private_fqdn" { value = azurerm_kubernetes_cluster.this.private_fqdn }
output "oidc_issuer_url" { value = azurerm_kubernetes_cluster.this.oidc_issuer_url }
output "registry_login_server" { value = azurerm_container_registry.this.login_server }
