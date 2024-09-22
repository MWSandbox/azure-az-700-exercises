terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.62.1"
    }
  }

  required_version = ">= 1.5.1"
}

provider "azurerm" {
  features {
  }
}

module "m01_unit4" {
  source = "./modules/m01-unit4"
}

module "m01_unit6" {
  count  = contains(var.module_list, "M01-Unit6") ? 1 : 0
  source = "./modules/m01-unit6"

  resource_group        = module.m01_unit4.resource_group_name
  core_services_vnet_id = module.m01_unit4.core_services_vnet.id
  manufacturing_vnet_id = module.m01_unit4.manufacturing_vnet.id
  research_vnet_id      = module.m01_unit4.research_vnet.id
  username              = var.username
}


module "m02_unit3" {
  count  = contains(var.module_list, "M02-Unit3") ? 1 : 0
  source = "./modules/m02-unit3"

  resource_group              = module.m01_unit4.resource_group_name
  core_services_vnet_name     = module.m01_unit4.core_services_vnet.name
  manufacturing_vnet_name     = module.m01_unit4.manufacturing_vnet.name
  core_services_vnet_location = module.m01_unit4.core_services_vnet.location
  manufacturing_vnet_location = module.m01_unit4.manufacturing_vnet.location
  username                    = var.username

  depends_on = [module.m01_unit4]
}

module "m02_unit7" {
  count  = contains(var.module_list, "M02-Unit7") ? 1 : 0
  source = "./modules/m02-unit7"

  resource_group              = module.m01_unit4.resource_group_name
  core_services_vnet_id       = module.m01_unit4.core_services_vnet.id
  core_services_vnet_name     = module.m01_unit4.core_services_vnet.name
  manufacturing_vnet_name     = module.m01_unit4.manufacturing_vnet.name
  core_services_vnet_location = module.m01_unit4.core_services_vnet.location
  manufacturing_vnet_location = module.m01_unit4.manufacturing_vnet.location
  username                    = var.username

  depends_on = [module.m01_unit4]
}

# module "m01-unit8" {
#   count = contains(var.module_list, "M01-Unit8") ? 1 : 0
#   source = "./modules/m01-unit8"

#   resource_group = module.m01_unit4.resource_group_name
#   core_services_vnet = module.m01_unit4.core_services_vnet
#   manufacturing_vnet = module.m01_unit4.manufacturing_vnet
# }