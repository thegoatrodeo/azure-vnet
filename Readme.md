---
title: Azure VNET Creation
tags: Azure VNET
---

# Azure VNET
This code is written and used as an example for  creating a simple Azure VNET. 

### main.tf 
The [Azure VNET module](https://registry.terraform.io/modules/Azure/vnet/azurerm/latest) can be used to quickly setup an Azure VNET. With a few variables passed in, a  resource group, subnets, Service Endpoints and tags can be created.  

```hcl tangle:./main.tf

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

```

### backend.tf 
The backend file is to specify the location and name of the state file.
Below we are storing state in the local current directory
The statefile will not be created until a `terraform init` is run. 

```hcl tangle:./backend.tf
terraform {
  required_version = "~> 1.0.11"
  backend "local" {
    path = "./terraform.tfstate"
  }
}
```

### providers.tf
The [provider file](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) is what Terraform Core interacts with in order to bring in different providers like AWS, Azure etc. In the following provider we are using the [AWS provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs).  To interact with the provider for Azure, the subscription ID, client ID, client secret and tenant ID. 

```hcl tangle:./providers.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}
```

### variables.tf
The following variables can be updated in the file or passed in during the execution of a `terraform plan` or a `terraform apply`

**Example:**
```
    terraform apply \
      -var="subscription_id=${ARM_SUBSCRIPTION_ID}" \ 
      -var="client_id=${ARM_CLIENT_ID}" \  
      -var="client_secret=${ARM_CLIENT_SECRET}" \ 
      -var="tenant_id=${ARM_TENANT_ID}" \ 
      -auto-approve
 ```

```hcl tangle:./variables.tf

variable "subscription_id" { 
  type    = string
  description = "Azure Subscription ID"
}

variable "client_id" { 
  type    = string
  description = "Azure Client ID"
}

variable "client_secret" { 
  type    = string
  description = "Azure Client secret"
  sensitive = true
}

variable "tenant_id" {
  type = string
  description = "Azure Tenant ID"
}

```
