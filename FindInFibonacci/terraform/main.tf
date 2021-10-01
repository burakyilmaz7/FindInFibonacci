   ##################################################
   # Terraform Config                               #
   ##################################################
   terraform {
     required_version = ">= __terraformVersion__"

     backend "azurerm" {
       resource_group_name  = "__backendAzureRmResourceGroupName__"
       storage_account_name = "__backendAzureRmStorageAccountName__"
       container_name       = "tfstate"
       key                  = "infra-__environment__-rg.tfstate"
     }

     required_providers {
       azurerm = {
         source  = "hashicorp/azurerm"
         version = "~> 2.73"
       }
     }
   }

   provider "azurerm" {
     features {}
     skip_provider_registration = true
   }

# Create Resource Group
resource "azurerm_resource_group" "britops" {
  name     = "__resource_name__"
  location = "__location__" 

  tags = {
      Environment = "__environment__"
    }

}

# Create Storage account
resource "azurerm_storage_account" "storage_account" {
  name                = "__storage_account_name__"
  resource_group_name = azurerm_resource_group.britops.name
  location                 = "__location__"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = {
      Environment = "__environment__"
    }

}

# Add function app service plan
resource "azurerm_app_service_plan" "asp" {
  name                = "__function_plan_name__"
  location            = azurerm_resource_group.britops.location
  resource_group_name = azurerm_resource_group.britops.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = "__function_app_name__"
  location                   = azurerm_resource_group.britops.location
  resource_group_name        = azurerm_resource_group.britops.name
  app_service_plan_id        = azurerm_app_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version = "~3"

  app_settings = {
  "FUNCTIONS_EXTENSION_VERSION" ="~3"
  "FUNCTIONS_WORKER_RUNTIME" = "dotnet"
  "AzureWebJobsStorage" = azurerm_storage_account.storage_account.primary_connection_string
  "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING"= azurerm_storage_account.storage_account.primary_connection_string
  }
}