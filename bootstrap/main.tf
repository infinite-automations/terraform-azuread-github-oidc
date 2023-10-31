terraform {
  required_version = "~>1.0"
}

variable "github_token" {
  description = "GitHub token for writing the secret"
  type        = string
  sensitive   = true
  default     = null
}

module "github-oidc" {
  source = "../examples/full"
  azure_application_api_access = [{
    api_name          = "MicrosoftGraph"
    role_permissions  = ["Application.ReadWrite.All"]
    scope_permissions = []
  }]
  azure_service_principal_subscription_roles = ["Owner"]
  github_repository_branches                 = ["main"]
  github_repository_tags                     = []
  github_repository_environments             = ["main", "pr"]
  github_repository_pull_request             = true
  github_token                               = var.github_token
}
