variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = null
}

variable "azure_owner_object_id" {
  description = "Azure AD application owner object ID"
  type        = string
  default     = null
}

variable "azure_application_name" {
  description = "Name of the Azure AD application"
  type        = string
}

variable "azure_application_api_access" {
  description = "List of API access permissions for the Azure AD application"
  type = list(object({
    api_name          = string
    role_permissions  = list(string)
    scope_permissions = list(string)
  }))
  default = []
}

variable "azure_service_principal_subscription_roles" {
  description = "Set of subscription roles to assign to the service principal"
  type        = set(string)
  default     = []
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
  description = "List of branches to create federated credentials for"
  type        = set(string)
  default     = []
}

variable "github_repository_tags" {
  description = "List of tags to create federated credentials for"
  type        = set(string)
  default     = []
}

variable "github_repository_environments" {
  description = "List of environments to create federated credentials for"
  type        = set(string)
  default     = []
}

variable "github_repository_pull_request" {
  description = "Create federated credentials for pull requests"
  type        = bool
  default     = false
}
