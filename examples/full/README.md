# Full Setup

Create an application that has federated identities for the `main` branch and corresponding pull request. Moreover the environments `main` and `pr` will be supported as well as the tags `1.0.0` and `1.0.1`

The name of the Azure AD application can be changed by setting the variable `azure_application_name`.

By providing a sensitive variable `github_token` with a PAT for the given repository the client ID of the client created application will be written into a GitHub secret.

<!-- BEGIN_TF_DOCS -->

## main.tf

```hcl
# This Terraform code creates a GitHub OIDC application in Azure AD and sets up federated credentials for a GitHub repository.
# The code creates an Azure AD application with API access permissions, assigns subscription roles to the service principal, and creates federated credentials for specified branches, tags, and environments.
# The code also creates GitHub secrets and environment secrets for the federated credentials, and sets up Dependabot secrets for the Azure AD application.
# The variables for the code include the Azure AD application name, API access permissions, subscription roles, GitHub repository owner and name, branches, tags, environments, and pull request settings.
# The code uses the GitHub OIDC module to create the Azure AD application and federated credentials.

# Define variables for the code
variable "azure_application_name" {
  description = "Name of the Azure AD application"
  type        = string
  default     = "github-oidc-test"
}

variable "azure_application_api_access" {
  description = "List of API access permissions for the Azure AD application"
  type = list(object({
    api_name          = string
    role_permissions  = list(string)
    scope_permissions = list(string)
  }))
  default = [{
    api_name          = "MicrosoftGraph"
    role_permissions  = ["Chat.Create", "Chat.Read.All", "Chat.ReadBasic.All"]
    scope_permissions = ["Chat.Create", "Chat.Read"]
  }]
}

variable "azure_service_principal_subscription_roles" {
  description = "List of subscription roles to assign to the service principal"
  type        = set(string)
  default     = ["Contributor"] # allow access to the subscription and the subscriptions RBAC
}

variable "github_repository_owner" {
  description = "Owner of the GitHub repository"
  type        = string
  default     = "infinite-automations"
}

variable "github_repository_name" {
  description = "Name of the GitHub repository"
  type        = string
  default     = "terraform-azuread-github-oidc"
}

variable "github_repository_branches" {
  description = "List of branches to create federated credentials for"
  type        = set(string)
  default     = ["main"]
}

variable "github_repository_tags" {
  description = "List of tags to create federated credentials for"
  type        = set(string)
  default     = ["1.0.0", "1.1.0"]
}

variable "github_repository_environments" {
  description = "List of environments to create federated credentials for"
  type        = set(string)
  default     = ["test", "prod"]
}

variable "github_repository_pull_request" {
  description = "Create federated credentials for pull requests"
  type        = bool
  default     = true
}

variable "github_token" {
  description = "GitHub token for writing the secret"
  type        = string
  sensitive   = true
  default     = null
}

# Define locals for the code
locals {

  set_secrets = nonsensitive(var.github_token == null)
  secret_envs = local.set_secrets ? [] : toset(var.github_repository_environments)
}

# Use the GitHub OIDC module to create the Azure AD application and federated credentials
module "github-oidc" {
  source = "../.."

  azure_application_name                     = var.azure_application_name
  azure_application_api_access               = var.azure_application_api_access
  azure_service_principal_subscription_roles = var.azure_service_principal_subscription_roles
  github_repository_owner                    = var.github_repository_owner
  github_repository_name                     = var.github_repository_name
  github_repository_branches                 = var.github_repository_branches
  github_repository_tags                     = var.github_repository_tags
  github_repository_environments             = var.github_repository_environments
  github_repository_pull_request             = var.github_repository_pull_request
}

# Create GitHub secrets for the federated credentials
resource "github_actions_secret" "tenant-id" {
  count           = local.set_secrets ? 0 : 1
  repository      = var.github_repository_name
  secret_name     = "ARM_TENANT_ID"
  plaintext_value = module.github-oidc.tenant_id
}

resource "github_actions_secret" "subscription-id" {
  count           = local.set_secrets ? 0 : 1
  repository      = var.github_repository_name
  secret_name     = "ARM_SUBSCRIPTION_ID"
  plaintext_value = module.github-oidc.subscription_id
}

resource "github_actions_secret" "client-id" {
  count           = local.set_secrets ? 0 : 1
  repository      = var.github_repository_name
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = module.github-oidc.client_id
}

# Create GitHub environment secrets for the federated credentials
resource "github_actions_environment_secret" "tenant-id" {
  for_each        = local.secret_envs
  repository      = var.github_repository_name
  environment     = each.key
  secret_name     = "ARM_TENANT_ID"
  plaintext_value = module.github-oidc.tenant_id
}

resource "github_actions_environment_secret" "subscription-id" {
  for_each        = local.secret_envs
  repository      = var.github_repository_name
  environment     = each.key
  secret_name     = "ARM_SUBSCRIPTION_ID"
  plaintext_value = module.github-oidc.subscription_id
}

resource "github_actions_environment_secret" "client-id" {
  for_each        = local.secret_envs
  repository      = var.github_repository_name
  environment     = each.key
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = module.github-oidc.client_id
}

# Set up Dependabot secrets for the Azure AD application
resource "github_dependabot_secret" "tenant-id" {
  count           = local.set_secrets ? 0 : 1
  repository      = var.github_repository_name
  secret_name     = "ARM_TENANT_ID"
  plaintext_value = module.github-oidc.tenant_id
}
resource "github_dependabot_secret" "subscription-id" {
  count           = local.set_secrets ? 0 : 1
  repository      = var.github_repository_name
  secret_name     = "ARM_SUBSCRIPTION_ID"
  plaintext_value = module.github-oidc.subscription_id
}

resource "github_dependabot_secret" "client-id" {
  count           = local.set_secrets ? 0 : 1
  repository      = var.github_repository_name
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = module.github-oidc.client_id
}
```

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~>1.0    |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | >=3.78.0 |
| <a name="requirement_github"></a> [github](#requirement_github)          | >=5.41.0 |

## Providers

| Name                                                      | Version  |
| --------------------------------------------------------- | -------- |
| <a name="provider_github"></a> [github](#provider_github) | >=5.41.0 |

## Resources

| Name                                                                                                                                                              | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [github_actions_environment_secret.client-id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret)       | resource |
| [github_actions_environment_secret.subscription-id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret) | resource |
| [github_actions_environment_secret.tenant-id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret)       | resource |
| [github_actions_secret.client-id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret)                               | resource |
| [github_actions_secret.subscription-id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret)                         | resource |
| [github_actions_secret.tenant-id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret)                               | resource |
| [github_dependabot_secret.client-id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/dependabot_secret)                         | resource |
| [github_dependabot_secret.subscription-id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/dependabot_secret)                   | resource |
| [github_dependabot_secret.tenant-id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/dependabot_secret)                         | resource |

## Inputs

| Name                                                                                                                                                            | Description                                                   | Type                                                                                                                                | Default                                                                                                                                                                                                                                            | Required |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_azure_application_api_access"></a> [azure_application_api_access](#input_azure_application_api_access)                                           | List of API access permissions for the Azure AD application   | <pre>list(object({<br/> api_name = string<br/> role_permissions = list(string)<br/> scope_permissions = list(string)<br/> }))</pre> | <pre>[<br/> {<br/> "api_name": "MicrosoftGraph",<br/> "role_permissions": [<br/> "Chat.Create",<br/> "Chat.Read.All",<br/> "Chat.ReadBasic.All"<br/> ],<br/> "scope_permissions": [<br/> "Chat.Create",<br/> "Chat.Read"<br/> ]<br/> }<br/>]</pre> |    no    |
| <a name="input_azure_application_name"></a> [azure_application_name](#input_azure_application_name)                                                             | Name of the Azure AD application                              | `string`                                                                                                                            | `"github-oidc-test"`                                                                                                                                                                                                                               |    no    |
| <a name="input_azure_service_principal_subscription_roles"></a> [azure_service_principal_subscription_roles](#input_azure_service_principal_subscription_roles) | List of subscription roles to assign to the service principal | `set(string)`                                                                                                                       | <pre>[<br/> "Contributor"<br/>]</pre>                                                                                                                                                                                                              |    no    |
| <a name="input_github_repository_branches"></a> [github_repository_branches](#input_github_repository_branches)                                                 | List of branches to create federated credentials for          | `set(string)`                                                                                                                       | <pre>[<br/> "main"<br/>]</pre>                                                                                                                                                                                                                     |    no    |
| <a name="input_github_repository_environments"></a> [github_repository_environments](#input_github_repository_environments)                                     | List of environments to create federated credentials for      | `set(string)`                                                                                                                       | <pre>[<br/> "test",<br/> "prod"<br/>]</pre>                                                                                                                                                                                                        |    no    |
| <a name="input_github_repository_name"></a> [github_repository_name](#input_github_repository_name)                                                             | Name of the GitHub repository                                 | `string`                                                                                                                            | `"terraform-azuread-github-oidc"`                                                                                                                                                                                                                  |    no    |
| <a name="input_github_repository_owner"></a> [github_repository_owner](#input_github_repository_owner)                                                          | Owner of the GitHub repository                                | `string`                                                                                                                            | `"infinite-automations"`                                                                                                                                                                                                                           |    no    |
| <a name="input_github_repository_pull_request"></a> [github_repository_pull_request](#input_github_repository_pull_request)                                     | Create federated credentials for pull requests                | `bool`                                                                                                                              | `true`                                                                                                                                                                                                                                             |    no    |
| <a name="input_github_repository_tags"></a> [github_repository_tags](#input_github_repository_tags)                                                             | List of tags to create federated credentials for              | `set(string)`                                                                                                                       | <pre>[<br/> "1.0.0",<br/> "1.1.0"<br/>]</pre>                                                                                                                                                                                                      |    no    |
| <a name="input_github_token"></a> [github_token](#input_github_token)                                                                                           | GitHub token for writing the secret                           | `string`                                                                                                                            | `null`                                                                                                                                                                                                                                             |    no    |

## Outputs

| Name                                                                             | Description           |
| -------------------------------------------------------------------------------- | --------------------- |
| <a name="output_client_id"></a> [client_id](#output_client_id)                   | AzureAD client ID     |
| <a name="output_subscription_id"></a> [subscription_id](#output_subscription_id) | Azure subscription ID |
| <a name="output_tenant_id"></a> [tenant_id](#output_tenant_id)                   | Azure tenant ID       |

<!-- END_TF_DOCS -->
