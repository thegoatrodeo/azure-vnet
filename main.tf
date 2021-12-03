
resource "azurerm_resource_group" "ztarg" {
  name     = "zt-azure-resource-group"
  location = "East US"
}

module "vnet" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = azurerm_resource_group.ztarg.name
  address_space       = ["10.1.0.0/16"]
  subnet_prefixes     = ["10.1.1.0/24", "10.1.2.0/24"]
  subnet_names        = ["zt-azure-subnet-a", "zt-azure-subnet-b"]

  subnet_service_endpoints = {
    subnet2 = ["Microsoft.Storage", "Microsoft.Sql"],
    subnet3 = ["Microsoft.AzureActiveDirectory"]
  }

  tags = {
    Terraform   = "true"
    Environment = "development"
  }

  depends_on = [azurerm_resource_group.ztarg]
}

