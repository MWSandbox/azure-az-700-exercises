output "resource_group_name" {
  value = azurerm_resource_group.contoso.name
}

output "core_services_vnet" {
  value = {
    id             = module.core_services_vnet.id
    name           = module.core_services_vnet.name
    location       = module.core_services_vnet.location
    subnets        = module.core_services_vnet.subnets
    nsg_name_to_id = module.core_services_vnet.nsg_name_to_id
  }
}

output "manufacturing_vnet" {
  value = {
    id             = module.manufacturing_vnet.id
    name           = module.manufacturing_vnet.name
    location       = module.manufacturing_vnet.location
    subnets        = module.manufacturing_vnet.subnets
    nsg_name_to_id = module.manufacturing_vnet.nsg_name_to_id
  }
}

output "research_vnet" {
  value = {
    id             = module.research_vnet.id
    name           = module.research_vnet.name
    location       = module.research_vnet.location
    subnets        = module.research_vnet.subnets
    nsg_name_to_id = module.research_vnet.nsg_name_to_id
  }
}