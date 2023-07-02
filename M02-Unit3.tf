module "core_services_vm" {
  source = "./modules/windows-vm"

  name = "CoreServices"
  resource_group = azurerm_resource_group.contoso.name
  vnet = module.core_services_vnet.name
  subnet = "DatabaseSubnet"
  username = var.username
  vm_size = "Standard_DS1_v2"
}

module "manufacturing_vm" {
  source = "./modules/windows-vm"

  name = "Manufacturing"
  resource_group = azurerm_resource_group.contoso.name
  vnet = module.manufacturing_vnet.name
  subnet = "ManufacturingSystemSubnet"
  username = var.username
  vm_size = "Standard_DS1_v2"
}

module "core_services_vnet_gateway" {
  source = "./modules/vnet-gateway"

  name = "CoreServices"
  resource_group = azurerm_resource_group.contoso.name
  vnet = module.core_services_vnet.name
  subnet = "GatewaySubnet"
}

module "manufacturing_vnet_gateway" {
  source = "./modules/vnet-gateway"

  name = "Manufacturing"
  resource_group = azurerm_resource_group.contoso.name
  vnet = module.manufacturing_vnet.name
  subnet = "GatewaySubnet"

  depends_on = [ module.manufacturing_vnet ]
}

resource "random_string" "shared_key" {
  length = 16
  special = true
  override_special = "-"
  min_lower = 1
  min_numeric = 1
  min_special = 1
  min_upper = 1
}

resource "azurerm_virtual_network_gateway_connection" "core_services_to_manufacturing" {
  name                = "CoreServicesGW-to-ManufacturingGW"
  location            = module.core_services_vnet.location
  resource_group_name = azurerm_resource_group.contoso.name

  type                       = "Vnet2Vnet"
  virtual_network_gateway_id      = module.core_services_vnet_gateway.id
  peer_virtual_network_gateway_id = module.manufacturing_vnet_gateway.id

  shared_key = random_string.shared_key.result
}

resource "azurerm_virtual_network_gateway_connection" "manufacturing_to_core_services" {
  name                = "ManufacturingGW-to-CoreServicesGW"
  location            = module.manufacturing_vnet.location
  resource_group_name = azurerm_resource_group.contoso.name

  type                       = "Vnet2Vnet"
  virtual_network_gateway_id      = module.manufacturing_vnet_gateway.id
  peer_virtual_network_gateway_id = module.core_services_vnet_gateway.id

  shared_key = random_string.shared_key.result
}