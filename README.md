# terraform-azuread-github-oidc

Terraform module to create an Azure AD application, service principal, and federated identities OIDC authentication with GitHub.

<!-- BEGIN_TF_DOCS -->


## Module Usage

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | 2.43.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.75.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 2.43.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.75.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_application.this](https://registry.terraform.io/providers/hashicorp/azuread/2.43.0/docs/resources/application) | resource |
| [azuread_application_federated_identity_credential.branch](https://registry.terraform.io/providers/hashicorp/azuread/2.43.0/docs/resources/application_federated_identity_credential) | resource |
| [azuread_application_federated_identity_credential.environment](https://registry.terraform.io/providers/hashicorp/azuread/2.43.0/docs/resources/application_federated_identity_credential) | resource |
| [azuread_application_federated_identity_credential.pull-request](https://registry.terraform.io/providers/hashicorp/azuread/2.43.0/docs/resources/application_federated_identity_credential) | resource |
| [azuread_application_federated_identity_credential.tag](https://registry.terraform.io/providers/hashicorp/azuread/2.43.0/docs/resources/application_federated_identity_credential) | resource |
| [azuread_service_principal.this](https://registry.terraform.io/providers/hashicorp/azuread/2.43.0/docs/resources/service_principal) | resource |
| [azurerm_role_assignment.sub-contributor](https://registry.terraform.io/providers/hashicorp/azurerm/3.75.0/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_application_name"></a> [azure\_application\_name](#input\_azure\_application\_name) | Name of the Azure AD application | `string` | n/a | yes |
| <a name="input_azure_principal_roles"></a> [azure\_principal\_roles](#input\_azure\_principal\_roles) | List of roles to assign to the service principal | `set(string)` | <pre>[<br>  "Contributor"<br>]</pre> | no |
| <a name="input_github_repository_branches"></a> [github\_repository\_branches](#input\_github\_repository\_branches) | List of branches to create a service principal for | `set(string)` | `[]` | no |
| <a name="input_github_repository_environments"></a> [github\_repository\_environments](#input\_github\_repository\_environments) | List of environments to create a service principal for | `set(string)` | `[]` | no |
| <a name="input_github_repository_name"></a> [github\_repository\_name](#input\_github\_repository\_name) | Name of the GitHub repository | `string` | n/a | yes |
| <a name="input_github_repository_owner"></a> [github\_repository\_owner](#input\_github\_repository\_owner) | Owner of the GitHub repository | `string` | n/a | yes |
| <a name="input_github_repository_pull_request"></a> [github\_repository\_pull\_request](#input\_github\_repository\_pull\_request) | Create a service principal for pull requests | `bool` | `false` | no |
| <a name="input_github_repository_tags"></a> [github\_repository\_tags](#input\_github\_repository\_tags) | List of tags to create a service principal for | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application"></a> [application](#output\_application) | AzureAD application created |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | AzureAD client ID |
| <a name="output_principal"></a> [principal](#output\_principal) | AzureAD principal created |


<!-- END_TF_DOCS -->