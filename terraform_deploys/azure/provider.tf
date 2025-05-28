terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.14"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "postgresql" {
  host     = var.postgresql_host
  port     = 5432
  username = var.AZURE_POSTGRESQL_USERNAME
  password = var.AZURE_POSTGRESQL_PASSWORD
  sslmode  = "require"
}
