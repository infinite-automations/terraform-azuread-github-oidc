output "application" {
  value       = azuread_application.this
  description = "AzureAD application created"
}

output "principal" {
  value       = azuread_service_principal.this
  description = "AzureAD principal created"
}

output "client_id" {
  value       = azuread_application.this.application_id
  description = "AzureAD client ID"
}
