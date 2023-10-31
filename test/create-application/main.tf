terraform {
  required_version = "~>1.0"
}

variable "azure_application_name" {
  description = "Name of the Azure AD application"
  type        = string
}

module "github-oidc" {
  source                         = "../../examples/full"
  azure_application_name         = var.azure_application_name
  github_repository_branches     = ["main"]
  github_repository_tags         = ["1.0.0", "1.0.1"]
  github_repository_environments = ["main", "pr"]
  github_repository_pull_request = true
}
