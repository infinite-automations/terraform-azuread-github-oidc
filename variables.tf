variable "azure_application_name" {
  description = "Name of the Azure AD application"
  type        = string
}

variable "azure_principal_roles" {
  description = "List of roles to assign to the service principal"
  type        = set(string)
  default     = ["Contributor"]
}

variable "github_repository_owner" {
  description = "Owner of the GitHub repository"
  type        = string
}

variable "github_repository_name" {
  description = "Name of the GitHub repository"
  type        = string
}

variable "github_repository_branches" {
  description = "List of branches to create a service principal for"
  type        = set(string)
  default     = []
}

variable "github_repository_tags" {
  description = "List of tags to create a service principal for"
  type        = set(string)
  default     = []
}

variable "github_repository_environments" {
  description = "List of environments to create a service principal for"
  type        = set(string)
  default     = []
}

variable "github_repository_pull_request" {
  description = "Create a service principal for pull requests"
  type        = bool
  default     = false
}
