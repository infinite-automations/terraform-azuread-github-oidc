terraform {
  backend "azurerm" {
    resource_group_name  = "base-infra"
    storage_account_name = "mbodenxpirit"
    container_name       = "tfstate"
    key                  = "terraform-azuread-github-oidc/test.terraform.tfstate"
  }
}
