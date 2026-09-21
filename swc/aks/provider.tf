terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
  }

  backend "azurerm" {
    tenant_id            = "9cdec346-9087-4758-a5a5-2144a3ed72d4"
    subscription_id      = "7d1c5864-c4b6-4404-be9e-4b7a353996ff"
    client_id            = "a0dcc81a-54ee-4267-a4a0-399c937e8492"
    resource_group_name  = "rg-swc-vessyinc-tfstate"
    storage_account_name = "stswcvessyinctfstate"
    container_name       = "aks"
    key                  = "aks.tfstate"
    use_oidc             = true
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  tenant_id       = "9cdec346-9087-4758-a5a5-2144a3ed72d4"
  subscription_id = "7d1c5864-c4b6-4404-be9e-4b7a353996ff"
  use_oidc        = true

  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }

  storage_use_azuread = true
}
