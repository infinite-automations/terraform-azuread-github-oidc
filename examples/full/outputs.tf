output "tenant_id" {
  value       = module.github-oidc.tenant_id
  description = "Azure tenant ID"
}

output "subscription_id" {
  value       = module.github-oidc.subscription_id
  description = "Azure subscription ID"
}

output "client_id" {
  value       = module.github-oidc.client_id
  description = "AzureAD client ID"
}
