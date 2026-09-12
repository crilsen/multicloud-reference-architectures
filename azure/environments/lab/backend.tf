terraform {
  backend "azurerm" {
    resource_group_name  = "replace-with-lab-state-rg"
    storage_account_name = "replacewithlabstate"
    container_name       = "tfstate"
    key                  = "azure/lab/terraform.tfstate"
  }
}
