output "resource_group_name" {
  description = "Workload resource group."
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

output "aks_fqdn" {
  description = "AKS API server FQDN (use with az aks get-credentials + kubelogin)."
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "aks_get_credentials_command" {
  description = "Fetch kubeconfig via Entra ID (no admin certs)."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.this.name} --name ${azurerm_kubernetes_cluster.this.name}"
}

output "postgres_fqdn" {
  description = "Private Flexible Server FQDN (not a secret). Used by ESO to template DATABASE_URL."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "postgres_administrator_login" {
  description = "PostgreSQL administrator login (not a secret)."
  value       = var.postgres_administrator_login
}

output "key_vault_name" {
  description = "Key Vault that holds secret *values* (set out-of-band)."
  value       = data.azurerm_key_vault.this.name
}

output "key_vault_uri" {
  description = "Key Vault URI."
  value       = data.azurerm_key_vault.this.vault_uri
}

output "public_ip_address" {
  description = "Single Standard public IP: AKS outbound SNAT + inbound (app LB or nginx Ingress)."
  value       = azurerm_public_ip.app.ip_address
}

output "app_url" {
  description = "NEXT_PUBLIC_APP_URL derived for the ConfigMap (https when TLS is on)."
  value       = local.app_url
}

output "tls_enabled" {
  description = "Whether nginx Ingress + Let's Encrypt are planned."
  value       = local.tls_enabled
}

output "seed_secrets_command" {
  description = "Out-of-band command to put secret values in Key Vault (run after bootstrap KV exists, before this root's first full apply)."
  value       = "${path.module}/scripts/seed-keyvault-secrets.sh ${data.azurerm_key_vault.this.name}"
}
