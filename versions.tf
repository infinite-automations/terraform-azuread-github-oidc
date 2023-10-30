terraform {
  required_version = "~>1.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.45.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.77.0"
    }
  }
}
