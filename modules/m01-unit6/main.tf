resource "azurerm_private_dns_zone" "contoso" {
  name                = "contoso.com"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "core_services" {
  name                  = "CoreServicesVnetLink"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.contoso.name
  virtual_network_id    = var.core_services_vnet_id
  registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "manufacturing" {
  name                  = "ManufacturingVnetLink"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.contoso.name
  virtual_network_id    = var.manufacturing_vnet_id
  registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "research" {
  name                  = "ResearchVnetLink"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.contoso.name
  virtual_network_id    = var.research_vnet_id
  registration_enabled = true
}