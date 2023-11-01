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
