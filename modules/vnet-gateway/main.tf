data "azurerm_virtual_network" "this" {
  name                = var.vnet
  resource_group_name = var.resource_group
}

data "azurerm_subnet" "this" {
  name                 = var.subnet
  virtual_network_name = var.vnet
  resource_group_name  = var.resource_group
}

resource "azurerm_public_ip" "this" {
  name                = "${var.name}-VnetGateway-ip"
  resource_group_name = var.resource_group
  location            = data.azurerm_virtual_network.this.location
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "this" {
  name                = "${var.name}VnetGateway"
  location            = data.azurerm_virtual_network.this.location
  resource_group_name = var.resource_group

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"
  generation    = "Generation1"

  ip_configuration {
    name                          = "${var.name}VnetGateway-ip"
    public_ip_address_id          = azurerm_public_ip.this.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.this.id
  }
}