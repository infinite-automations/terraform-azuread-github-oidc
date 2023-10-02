locals {
  scope = data.azurerm_subscription.this.id
}

data "azurerm_subscription" "this" {
}

data "azuread_client_config" "current" {}

data "azuread_user" "this" {
  object_id = data.azuread_client_config.current.object_id
}

resource "azuread_application" "this" {
  display_name = var.azure_application_name
  web {
    implicit_grant {
      access_token_issuance_enabled = true
    }
  }
  owners = [data.azuread_client_config.current.object_id, data.azuread_user.this.object_id]
}

resource "azuread_service_principal" "this" {
  application_id               = azuread_application.this.application_id
  app_role_assignment_required = false
  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_role_assignment" "sub-contributor" {
  for_each             = var.azure_principal_roles
  scope                = local.scope
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
  for_each              = var.github_repository_branches
  application_object_id = azuread_application.this.id
  display_name          = "az-oidc-branch-${each.key}"
  description           = "deployments for repository cloud-cicd-exploration and branch ${each.key}"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_repository_owner}/${var.github_repository_name}:ref:refs/heads/${each.key}"
}

resource "azuread_application_federated_identity_credential" "tag" {
  for_each              = var.github_repository_tags
  application_object_id = azuread_application.this.id
  display_name          = "az-oidc-tag-${each.key}"
  description           = "deployments for repository ${var.github_repository_name} and branch ${each.key}"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_repository_owner}/${var.github_repository_name}:ref:refs/heads/${each.key}"
}

resource "azuread_application_federated_identity_credential" "pull-request" {
  count                 = var.github_repository_pull_request ? 1 : 0
  application_object_id = azuread_application.this.id
  display_name          = "az-oidc-pr"
  description           = "deployments for repository ${var.github_repository_name}"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_repository_owner}/${var.github_repository_name}:pull_request"
}

resource "azuread_application_federated_identity_credential" "environment" {
  for_each              = var.github_repository_environments
  application_object_id = azuread_application.this.id
  display_name          = "az-oidc-env-${each.key}"
  description           = "deployments for repository ${var.github_repository_name}"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_repository_owner}/${var.github_repository_name}::environment:${each.key}"
}

