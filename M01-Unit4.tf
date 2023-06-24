resource "azurerm_resource_group" "contoso" {
  name     = "ContosoResourceGroup"
  location = "East US"
}

module "core_services_vnet" {
  source = "./modules/vnet"

  name = "CoreServicesVnet"
  location  = "East US"
  resource_group_name = azurerm_resource_group.contoso.name
  cidr = "10.20.0.0/16"
  subnets = [
    {name = "GatewaySubnet", cidr = "10.20.0.0/27"},
    {name = "SharedServicesSubnet", cidr = "10.20.10.0/24"},
    {name = "DatabaseSubnet", cidr = "10.20.20.0/24"},
    {name = "PublicWebServiceSubnet", cidr = "10.20.30.0/24"}
  ]
}

module "manufacturing_vnet" {
  source = "./modules/vnet"

  name = "ManufacturingVnet"
  location  = "West Europe"
  resource_group_name = azurerm_resource_group.contoso.name
  cidr = "10.30.0.0/16"
  subnets = [
    {name = "ManufacturingSystemSubnet", cidr = "10.30.10.0/24"},
    {name = "SensorSubnet1", cidr = "10.30.20.0/24"},
    {name = "SensorSubnet2", cidr = "10.30.21.0/24"},
    {name = "SensorSubnet3", cidr = "10.30.22.0/24"}
  ]
}

module "research_vnet" {
  source = "./modules/vnet"

  name = "ResearchVnet"
  location  = "Southeast Asia"
  resource_group_name = azurerm_resource_group.contoso.name
  cidr = "10.40.0.0/16"
  subnets = [
    {name = "ResearchSystemSubnet", cidr = "10.40.0.0/24"}
  ]
}
