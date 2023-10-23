# terraform-azuread-github-oidc

![Semantic Release](https://github.com/m4s-b3n/terraform-azuread-github-oidc/actions/workflows/test-and-release.yml/badge.svg)

Terraform module to setup GitHub OIDC in Microsoft Azure, creating an Azure AD application, service principal, and federated identities.

<!-- BEGIN_TF_DOCS -->


## Module Usage

```hcl
terraform {

  required_version = "~>1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.40.0"
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

For a detailed documentation see the [full example](examples/full/README.md)

## Github Workflow Example

```hcl
name: Deploy using OIDC

# choose any triggers
on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]

# permissions required
# oidc requires to cretate id-tokens
permissions:
  contents: read
  id-token: write

# environment variables to set
# can also be set on job level
env:
  ARM_USE_OIDC: true
  ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
  ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

# sample
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Terraform fmt
        run: terraform fmt -check -no-color
      - name: Terraform Init
        run: terraform init -no-color
      - name: Terraform Validate
        run: terraform validate -no-color
      - name: Terraform Plan
        run: terraform plan -no-color
      - name: Terraform Apply
        run: terraform apply -auto-approve -no-color
      - name: Terraform Destroy
        run: terraform destroy -auto-approve -no-color
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | 2.44.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.76.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 2.44.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.76.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_application.this](https://registry.terraform.io/providers/hashicorp/azuread/2.44.0/docs/resources/application) | resource |
| [azuread_application_federated_identity_credential.branch](https://registry.terraform.io/providers/hashicorp/azuread/2.44.0/docs/resources/application_federated_identity_credential) | resource |
| [azuread_application_federated_identity_credential.environment](https://registry.terraform.io/providers/hashicorp/azuread/2.44.0/docs/resources/application_federated_identity_credential) | resource |
| [azuread_application_federated_identity_credential.pull-request](https://registry.terraform.io/providers/hashicorp/azuread/2.44.0/docs/resources/application_federated_identity_credential) | resource |
| [azuread_application_federated_identity_credential.tag](https://registry.terraform.io/providers/hashicorp/azuread/2.44.0/docs/resources/application_federated_identity_credential) | resource |
| [azuread_service_principal.this](https://registry.terraform.io/providers/hashicorp/azuread/2.44.0/docs/resources/service_principal) | resource |
| [azurerm_role_assignment.sub-contributor](https://registry.terraform.io/providers/hashicorp/azurerm/3.76.0/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_application_name"></a> [azure\_application\_name](#input\_azure\_application\_name) | Name of the Azure AD application | `string` | n/a | yes |
| <a name="input_github_repository_name"></a> [github\_repository\_name](#input\_github\_repository\_name) | Name of the GitHub repository | `string` | n/a | yes |
| <a name="input_github_repository_owner"></a> [github\_repository\_owner](#input\_github\_repository\_owner) | Owner of the GitHub repository | `string` | n/a | yes |
| <a name="input_azure_principal_roles"></a> [azure\_principal\_roles](#input\_azure\_principal\_roles) | List of roles to assign to the service principal | `set(string)` | <pre>[<br>  "Contributor"<br>]</pre> | no |
| <a name="input_github_repository_branches"></a> [github\_repository\_branches](#input\_github\_repository\_branches) | List of branches to create a service principal for | `set(string)` | `[]` | no |
| <a name="input_github_repository_environments"></a> [github\_repository\_environments](#input\_github\_repository\_environments) | List of environments to create a service principal for | `set(string)` | `[]` | no |
| <a name="input_github_repository_pull_request"></a> [github\_repository\_pull\_request](#input\_github\_repository\_pull\_request) | Create a service principal for pull requests | `bool` | `false` | no |
| <a name="input_github_repository_tags"></a> [github\_repository\_tags](#input\_github\_repository\_tags) | List of tags to create a service principal for | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application"></a> [application](#output\_application) | AzureAD application created |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | AzureAD client ID |
| <a name="output_principal"></a> [principal](#output\_principal) | AzureAD principal created |


<!-- END_TF_DOCS -->

## Changelog
See the [Changelog](./CHANGELOG.md) file for details