provider "azurerm" {
  features {}
}

provider "github" {
  owner = var.github_repository_owner
  token = var.github_token
}
