output "azuread_application" {
  value       = azuread_application.this
  description = "AzureAD application created"
}

output "azuread_application_owner" {
  value       = local.owner
  description = "AzureAD application owner"
}

output "azuread_service_principal" {
  value       = azuread_service_principal.this
  description = "AzureAD principal created"
}

output "tenant_id" {
  value       = data.azuread_client_config.current.tenant_id
  description = "Azure tenant ID"
}

output "subscription_id" {
  value       = local.subscription_id
  description = "Azure subscription ID"
}

output "client_id" {
  value       = azuread_application.this.client_id
  description = "AzureAD client ID"
}
