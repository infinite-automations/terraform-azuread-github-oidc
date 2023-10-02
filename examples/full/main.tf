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

  backend "azurerm" {
  }
}

provider "azuread" {
}

provider "azurerm" {
  features {}
}

provider "github" {
  owner = local.github_repository_owner
  token = var.github_token
}

variable "github_token" {
  description = "GitHub token for writing the secret"
  type        = string
  default     = null
}

variable "github_branches" {
  description = "Branches to enable GitHub OIDC for"
  type        = set(string)
  default     = ["main"]
}

variable "github_tags" {
  description = "Tags to enable GitHub OIDC for"
  type        = set(string)
  default     = ["1.0.0"]
}

variable "github_environments" {
  description = "Environments to enable GitHub OIDC for"
  type        = set(string)
  default     = ["dev", "test", "prod"]
}

locals {
  github_repository_owner = "m4s-b3n"
  github_repository_name  = "terraform-azuread-github-oidc"
}

variable "azure_application_name" {
  description = "Name of the Azure AD application"
  type        = string
  default     = null
}

module "github-oidc" {
  source = "../.."

  azure_application_name         = var.azure_application_name
  azure_principal_roles          = ["Contributor"]
  github_repository_owner        = local.github_repository_owner
  github_repository_name         = local.github_repository_name
  github_repository_branches     = var.github_branches
  github_repository_tags         = var.github_tags
  github_repository_environments = var.github_environments
  github_repository_pull_request = true
}

resource "github_actions_secret" "client-id" {
  count           = (var.github_token == null) ? 0 : 1
  repository      = local.github_repository_name
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = module.github-oidc.client_id
}
