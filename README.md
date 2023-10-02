# terraform-azuread-github-oidc

Terraform module to create an Azure AD application, service principal, and federated identities OIDC authentication with GitHub.

<!-- BEGIN_TF_DOCS -->
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

## Modules

No modules.

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
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/2.43.0/docs/data-sources/client_config) | data source |
| [azuread_user.this](https://registry.terraform.io/providers/hashicorp/azuread/2.43.0/docs/data-sources/user) | data source |
| [azurerm_subscription.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.75.0/docs/data-sources/subscription) | data source |

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