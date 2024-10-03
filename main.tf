terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.3.0"
    }
  }

  required_version = ">= 1.9"
}

provider "azurerm" {
  features {
  }
}

module "m01_unit4" {
  count = contains(var.module_list, "M01-Unit4") ? 1 : 0

  source = "./modules/m01-unit4"
}

module "m01_unit6" {
  count  = contains(var.module_list, "M01-Unit6") ? 1 : 0
  source = "./modules/m01-unit6"

  resource_group        = module.m01_unit4[0].resource_group_name
  core_services_vnet_id = module.m01_unit4[0].core_services_vnet.id
  manufacturing_vnet_id = module.m01_unit4[0].manufacturing_vnet.id
  research_vnet_id      = module.m01_unit4[0].research_vnet.id
  username              = var.username
}


module "m02_unit3" {
  count  = contains(var.module_list, "M02-Unit3") ? 1 : 0
  source = "./modules/m02-unit3"

  resource_group              = module.m01_unit4[0].resource_group_name
  core_services_vnet_name     = module.m01_unit4[0].core_services_vnet.name
  manufacturing_vnet_name     = module.m01_unit4[0].manufacturing_vnet.name
  core_services_vnet_location = module.m01_unit4[0].core_services_vnet.location
  manufacturing_vnet_location = module.m01_unit4[0].manufacturing_vnet.location
  username                    = var.username

  depends_on = [module.m01_unit4[0]]
}

module "m02_unit7" {
  count  = contains(var.module_list, "M02-Unit7") ? 1 : 0
  source = "./modules/m02-unit7"

  resource_group              = module.m01_unit4[0].resource_group_name
  core_services_vnet_id       = module.m01_unit4[0].core_services_vnet.id
  core_services_vnet_name     = module.m01_unit4[0].core_services_vnet.name
  manufacturing_vnet_name     = module.m01_unit4[0].manufacturing_vnet.name
  core_services_vnet_location = module.m01_unit4[0].core_services_vnet.location
  manufacturing_vnet_location = module.m01_unit4[0].manufacturing_vnet.location
  username                    = var.username

  depends_on = [module.m01_unit4[0]]
}

# module "m01-unit8" {
#   count = contains(var.module_list, "M01-Unit8") ? 1 : 0
#   source = "./modules/m01-unit8"

#   resource_group = module.m01_unit4[0].resource_group_name
#   core_services_vnet = module.m01_unit4[0].core_services_vnet
#   manufacturing_vnet = module.m01_unit4[0].manufacturing_vnet
# }

module "m04_unit4" {
  count  = contains(var.module_list, "M04-Unit4") ? 1 : 0
  source = "./modules/m04-unit4"

  resource_group              = module.m01_unit4[0].resource_group_name
  core_services_vnet_name     = module.m01_unit4[0].core_services_vnet.name
  core_services_vnet_location = module.m01_unit4[0].core_services_vnet.location
  bastion_subnet_id           = module.m01_unit4[0].core_services_vnet.subnets["AzureBastionSubnet"]
  shared_services_subnet_id   = module.m01_unit4[0].core_services_vnet.subnets["SharedServicesSubnet"]
  username                    = var.username
}

module "m04_unit6" {
  count  = contains(var.module_list, "M04-Unit6") ? 1 : 0
  source = "./modules/m04-unit6"

  location = "germanywestcentral"
}

module "m05_unit4" {
  count  = contains(var.module_list, "M05-Unit4") ? 1 : 0
  source = "./modules/m05-unit4"

  resource_group                = module.m01_unit4[0].resource_group_name
  core_services_vnet_name       = module.m01_unit4[0].core_services_vnet.name
  core_services_vnet_location   = module.m01_unit4[0].core_services_vnet.location
  public_web_services_subnet_id = module.m01_unit4[0].core_services_vnet.subnets["PublicWebServiceSubnet"]
  shared_services_subnet_id     = module.m01_unit4[0].core_services_vnet.subnets["SharedServicesSubnet"]
  bastion_subnet_id             = module.m01_unit4[0].core_services_vnet.subnets["AzureBastionSubnet"]
  username                      = var.username

  depends_on = [module.m01_unit4[0]]
}

module "m05_unit6" {
  count  = contains(var.module_list, "M05-Unit6") ? 1 : 0
  source = "./modules/m05-unit6"

  resource_group         = module.m01_unit4[0].resource_group_name
  application_gateway_ip = module.m05_unit4[0].application_gateway_ip

  depends_on = [module.m05_unit4]
}

