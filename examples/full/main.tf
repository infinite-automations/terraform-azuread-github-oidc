terraform {
  required_version = "~>1.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.43.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }
    github = {
      source  = "integrations/github"
      version = "5.39.0"
    }
  }
}

provider "azuread" {
}

provider "azurerm" {
  features {}
}

provider "github" {
  owner = local.github_repository_owner
  token = var.github_repository_PAT
}

variable "github_repository_PAT" {
  description = "GitHub personal access token"
  type        = string
  default     = null
}

locals {
  github_repository_owner = "m4s-b3n"
  github_repository_name  = "playground"
}

module "github-oidc" {
  source = "../.."

  azure_application_name         = "github-oidc-test"
  azure_principal_roles          = ["Contributor"]
  github_repository_owner        = local.github_repository_owner
  github_repository_name         = local.github_repository_name
  github_repository_branches     = ["main"]
  github_repository_tags         = ["0.0.1"]
  github_repository_environments = ["dev", "test", "prod"]
  github_repository_pull_request = true
}

resource "github_actions_secret" "client-id" {
  count           = (var.github_repository_PAT == null) ? 0 : 1
  repository      = local.github_repository_name
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = module.github-oidc.client_id
}
