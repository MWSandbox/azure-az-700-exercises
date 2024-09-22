output "resource_group_name" {
  value = azurerm_resource_group.contoso.name
}

output "core_services_vnet" {
  value = {
    id       = module.core_services_vnet.id
    name     = module.core_services_vnet.name
    location = module.core_services_vnet.location
  }
}

output "manufacturing_vnet" {
  value = {
    id       = module.manufacturing_vnet.id
    name     = module.manufacturing_vnet.name
    location = module.manufacturing_vnet.location
  }
}

output "research_vnet" {
  value = {
    id       = module.research_vnet.id
    name     = module.research_vnet.name
    location = module.research_vnet.location
  }
}