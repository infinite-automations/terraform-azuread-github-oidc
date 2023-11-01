locals {
  subscription_id = coalesce(var.azure_subscription_id, data.azurerm_subscription.current.subscription_id)
  owner           = coalesce(var.azure_owner_object_id, data.azuread_client_config.current.object_id)

  api_names = toset([for access in var.azure_application_api_access : access.api_name])

  api_access_map = { for access in var.azure_application_api_access :
    data.azuread_application_published_app_ids.well_known.result[access.api_name] => {
      role_ids  = [for role_name in access.role_permissions : data.azuread_service_principal.msgraph[access.api_name].app_role_ids[role_name]]
      scope_ids = [for scope_name in access.scope_permissions : data.azuread_service_principal.msgraph[access.api_name].oauth2_permission_scope_ids[scope_name]]
  } }
}

data "azurerm_subscription" "current" {}

data "azuread_client_config" "current" {}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  for_each  = local.api_names
  client_id = data.azuread_application_published_app_ids.well_known.result[each.key]
}

resource "azuread_application" "this" {
  display_name = var.azure_application_name
  owners       = [local.owner]

  web {
    implicit_grant {
      access_token_issuance_enabled = true
    }
  }

  lifecycle {
    ignore_changes = [
      required_resource_access
    ]
  }
}

resource "azuread_application_api_access" "this" {
  for_each       = local.api_access_map
  application_id = azuread_application.this.id
  api_client_id  = each.key
  role_ids       = each.value.role_ids
  scope_ids      = each.value.scope_ids
}

resource "azuread_service_principal" "this" {
  client_id                    = azuread_application.this.client_id
  app_role_assignment_required = false
  owners                       = [local.owner]

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_role_assignment" "this" {
  for_each             = var.azure_service_principal_subscription_roles
  scope                = format("/subscriptions/%s", local.subscription_id)
  role_definition_name = each.key
  principal_id         = azuread_service_principal.this.id
  // If new SP there  may be replciation lag this disables validation
  skip_service_principal_aad_check = true
  lifecycle {
    ignore_changes = [
      scope,
    ]
  }
}

resource "azuread_application_federated_identity_credential" "branch" {
  for_each       = var.github_repository_branches
  application_id = azuread_application.this.id
  display_name   = "az-oidc-branch-${each.key}"
  description    = "deployments for repository cloud-cicd-exploration and branch ${each.key}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_repository_owner}/${var.github_repository_name}:ref:refs/heads/${each.key}"
}

resource "azuread_application_federated_identity_credential" "tag" {
  for_each       = var.github_repository_tags
  application_id = azuread_application.this.id
  display_name   = "az-oidc-tag-${each.key}"
  description    = "deployments for repository ${var.github_repository_name} and branch ${each.key}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_repository_owner}/${var.github_repository_name}:ref:refs/heads/${each.key}"
}

resource "azuread_application_federated_identity_credential" "pull-request" {
  count          = var.github_repository_pull_request ? 1 : 0
  application_id = azuread_application.this.id
  display_name   = "az-oidc-pr"
  description    = "deployments for repository ${var.github_repository_name}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_repository_owner}/${var.github_repository_name}:pull_request"
}

resource "azuread_application_federated_identity_credential" "environment" {
  for_each       = var.github_repository_environments
  application_id = azuread_application.this.id
  display_name   = "az-oidc-env-${each.key}"
  description    = "deployments for repository ${var.github_repository_name}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_repository_owner}/${var.github_repository_name}:environment:${each.key}"
}

