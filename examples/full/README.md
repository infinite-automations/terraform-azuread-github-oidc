# Full Setup

Create an application that has federated identities for the `main` branch and corresponding pull request. Moreover the environments `main` and `pr` will be supported as well as the tags `1.0.0` and `1.0.1`

The name of the Azure AD application can be changed by setting the variable `azure_application_name`.

By providing a sensitive variable `github_token` with a PAT for the given repository the client ID of the client created application will be written into a GitHub secret.

<!-- BEGIN_TF_DOCS -->


## main.tf

```hcl
terraform {

  required_version = "~>1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.39.0"
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
  github_repository_owner = "m4s-b3n"
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.76.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 5.39.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 5.39.0 |

## Resources

| Name | Type |
|------|------|
| [github_actions_secret.client-id](https://registry.terraform.io/providers/integrations/github/5.39.0/docs/resources/actions_secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_application_name"></a> [azure\_application\_name](#input\_azure\_application\_name) | Name of the Azure AD application | `string` | `"github-oidc-test"` | no |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | GitHub token for writing the secret | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | AzureAD client ID |


<!-- END_TF_DOCS -->