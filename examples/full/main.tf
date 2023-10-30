terraform {

  required_version = "~>1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.41.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.76.0"
    }
  }

  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}

provider "github" {
  owner = local.github_repository_owner
  token = var.github_token
}

variable "azure_application_name" {
  description = "Name of the Azure AD application"
  type        = string
  default     = "github-oidc-test"
}

variable "github_token" {
  description = "GitHub token for writing the secret"
  type        = string
  default     = null
}

locals {
  github_repository_owner = "infinite-automations"
  github_repository_name  = "terraform-azuread-github-oidc"

  github_branches     = ["main"]
  github_environments = ["main", "pr"]
  github_tags         = ["1.0.0", "1.0.1"]
  github_pull_request = true
}

module "github-oidc" {
  source = "../.."

  azure_application_name         = var.azure_application_name
  azure_principal_roles          = ["Contributor"]
  github_repository_owner        = local.github_repository_owner
  github_repository_name         = local.github_repository_name
  github_repository_branches     = local.github_branches
  github_repository_tags         = local.github_tags
  github_repository_environments = local.github_environments
  github_repository_pull_request = local.github_pull_request
}

resource "github_actions_secret" "client-id" {
  count           = (var.github_token == null) ? 0 : 1
  repository      = local.github_repository_name
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = module.github-oidc.client_id
}

output "client_id" {
  value       = module.github-oidc.client_id
  description = "AzureAD client ID"
}
