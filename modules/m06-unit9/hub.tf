resource "random_string" "psk" {
  length           = 16
  special          = true
  override_special = "!-_."
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
}

resource "azurerm_virtual_wan" "this" {
  name                = "contoso"
  resource_group_name = var.resource_group
  location            = local.wan_location
  type                = "Standard"
}

resource "azurerm_virtual_hub" "this" {
  name                = "contoso"
  resource_group_name = var.resource_group
  location            = azurerm_virtual_wan.this.location
  virtual_wan_id      = azurerm_virtual_wan.this.id
  address_prefix      = "10.0.0.0/16"
  sku                 = "Standard"
}

resource "azurerm_virtual_hub_connection" "hub_to_core_services_vnet" {
  name                      = "hub-to-core-service-connection"
  virtual_hub_id            = azurerm_virtual_hub.this.id
  remote_virtual_network_id = var.core_services_vnet_id
}

resource "azurerm_virtual_hub_connection" "hub_to_manufacturing_vnet" {
  name                      = "hub-to-manufacturing-connection"
  virtual_hub_id            = azurerm_virtual_hub.this.id
  remote_virtual_network_id = var.manufacturing_vnet_id
}