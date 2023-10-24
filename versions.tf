terraform {
  required_version = "~>1.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.44.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.77.0"
    }
  }
}
