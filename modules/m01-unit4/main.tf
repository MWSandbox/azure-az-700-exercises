resource "azurerm_resource_group" "contoso" {
  name     = "ContosoResourceGroup"
  location = "East US"
}

module "core_services_vnet" {
  source = "./../vnet"

  name                = "CoreServicesVnet"
  location            = "East US"
  resource_group_name = azurerm_resource_group.contoso.name
  cidr                = "10.20.0.0/16"
  subnets = {
    "GatewaySubnet"          = "10.20.0.0/27"
    "SharedServicesSubnet"   = "10.20.10.0/24"
    "DatabaseSubnet"         = "10.20.20.0/24"
    "PublicWebServiceSubnet" = "10.20.30.0/24"
    "AzureBastionSubnet"     = "10.20.40.0/24"
  }
}

module "manufacturing_vnet" {
  source = "./../vnet"

  name                = "ManufacturingVnet"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.contoso.name
  cidr                = "10.30.0.0/16"
  subnets = {
    "GatewaySubnet"             = "10.30.0.0/27"
    "ManufacturingSystemSubnet" = "10.30.10.0/24"
    "SensorSubnet1"             = "10.30.20.0/24"
    "SensorSubnet2"             = "10.30.21.0/24"
    "SensorSubnet3"             = "10.30.22.0/24"
  }
}

module "research_vnet" {
  source = "./../vnet"

  name                = "ResearchVnet"
  location            = "Southeast Asia"
  resource_group_name = azurerm_resource_group.contoso.name
  cidr                = "10.40.0.0/16"
  subnets = {
    "ResearchSystemSubnet" = "10.40.0.0/24"
  }
}
