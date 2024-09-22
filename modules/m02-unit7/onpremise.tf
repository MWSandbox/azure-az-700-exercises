data "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  virtual_network_name = var.manufacturing_vnet_name
  resource_group_name  = var.resource_group
}

resource "azurerm_public_ip" "onpremise" {
  name                = "onpremise"
  location            = var.manufacturing_vnet_location
  resource_group_name = var.resource_group

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vpn_s2s" {
  name                = "vpn-onpremise-s2s-gateway"
  location            = var.manufacturing_vnet_location
  resource_group_name = var.resource_group

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vpnGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.onpremise.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.gateway.id
  }
}

resource "azurerm_local_network_gateway" "hub" {
  name                = "local-gateway-to-hub"
  resource_group_name = var.resource_group
  location            = var.manufacturing_vnet_location
  address_space       = ["10.0.0.0/16", "10.20.0.0/16"]
  gateway_address     = [for ip in tolist(azurerm_vpn_gateway.onpremise.bgp_settings[0].instance_0_bgp_peering_address[0].tunnel_ips) : ip if !startswith(ip, "10.0")][0]
}

resource "azurerm_virtual_network_gateway_connection" "onpremise_to_hub" {
  name                = "onpremise-to-hub-connection"
  location            = var.manufacturing_vnet_location
  resource_group_name = var.resource_group

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_s2s.id
  local_network_gateway_id   = azurerm_local_network_gateway.hub.id

  shared_key = random_string.psk.result
}