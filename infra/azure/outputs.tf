output "resource_group_name" {
  description = "Resource group that holds the lean Torqvoice stack."
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Azure region (Switzerland North)."
  value       = azurerm_resource_group.this.location
}

output "aks_name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.this.name
}

output "aks_get_credentials_command" {
  description = "az CLI command to fetch kubeconfig after an approved apply."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.this.name} --name ${azurerm_kubernetes_cluster.this.name}"
}

output "postgres_fqdn" {
  description = "Private FQDN of the Flexible Server (reachable from AKS in the same VNet)."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "postgres_administrator_login" {
  description = "PostgreSQL administrator login."
  value       = var.postgres_administrator_login
}

output "postgres_administrator_password" {
  description = "Generated PostgreSQL administrator password."
  value       = random_password.postgres.result
  sensitive   = true
}

output "database_url" {
  description = "DATABASE_URL injected into the Torqvoice secret (sslmode=require)."
  value       = local.database_url
  sensitive   = true
}

output "better_auth_secret" {
  description = "BETTER_AUTH_SECRET used by the workload. Store this outside Terraform state backups if you need disaster recovery without state."
  value       = local.better_auth_secret
  sensitive   = true
}

output "public_ip_address" {
  description = "Static public IP attached to the HTTP LoadBalancer."
  value       = azurerm_public_ip.app.ip_address
}

output "app_url" {
  description = "NEXT_PUBLIC_APP_URL. HTTP until TLS is added (TODO)."
  value       = local.app_url
}

output "https_todo" {
  description = "HTTPS is out of scope for this lean first bring-up."
  value       = "TODO: put TLS in front of Service/torqvoice (ingress or Application Gateway). Do not expose this LoadBalancer as the long-term public URL."
}
