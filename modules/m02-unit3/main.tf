module "core_services_vm" {
  source = "./../windows-vm"

  name           = "CoreServices"
  resource_group = var.resource_group
  vnet           = var.core_services_vnet_name
  subnet         = "DatabaseSubnet"
  username       = var.username
  vm_size        = "Standard_DS1_v2"
}

module "manufacturing_vm" {
  source = "./../windows-vm"

  name           = "Manufacturing"
  resource_group = var.resource_group
  vnet           = var.manufacturing_vnet_name
  subnet         = "ManufacturingSystemSubnet"
  username       = var.username
  vm_size        = "Standard_DS1_v2"
}

module "core_services_vnet_gateway" {
  source = "./../vnet-gateway"

  name           = "CoreServices"
  resource_group = var.resource_group
  vnet           = var.core_services_vnet_name
  subnet         = "GatewaySubnet"
}

module "manufacturing_vnet_gateway" {
  source = "./../vnet-gateway"

  name           = "Manufacturing"
  resource_group = var.resource_group
  vnet           = var.manufacturing_vnet_name
  subnet         = "GatewaySubnet"
}

resource "random_string" "shared_key" {
  length           = 16
  special          = true
  override_special = "-"
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
}

resource "azurerm_virtual_network_gateway_connection" "core_services_to_manufacturing" {
  name                = "CoreServicesGW-to-ManufacturingGW"
  location            = var.core_services_vnet_location
  resource_group_name = var.resource_group

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = module.core_services_vnet_gateway.id
  peer_virtual_network_gateway_id = module.manufacturing_vnet_gateway.id

  shared_key = random_string.shared_key.result
}

resource "azurerm_virtual_network_gateway_connection" "manufacturing_to_core_services" {
  name                = "ManufacturingGW-to-CoreServicesGW"
  location            = var.manufacturing_vnet_location
  resource_group_name = var.resource_group

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = module.manufacturing_vnet_gateway.id
  peer_virtual_network_gateway_id = module.core_services_vnet_gateway.id

  shared_key = random_string.shared_key.result
}