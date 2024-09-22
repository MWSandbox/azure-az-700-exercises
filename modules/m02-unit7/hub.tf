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
  location            = "germanywestcentral"
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

resource "azurerm_vpn_site" "onpremise" {
  name                = "onpremise-site"
  resource_group_name = var.resource_group
  location            = azurerm_virtual_wan.this.location
  virtual_wan_id      = azurerm_virtual_wan.this.id
  address_cidrs       = ["10.30.0.0/16"]

  link {
    name       = "onpremise-link"
    ip_address = azurerm_public_ip.onpremise.ip_address
  }

  depends_on = [azurerm_virtual_network_gateway.vpn_s2s]
}

resource "azurerm_vpn_gateway" "onpremise" {
  name                = "onpremise-s2s-gateway"
  location            = azurerm_virtual_hub.this.location
  resource_group_name = var.resource_group
  virtual_hub_id      = azurerm_virtual_hub.this.id
}

resource "azurerm_vpn_gateway_connection" "hub_to_onpremise" {
  name               = "hub-to-onpremise-connection"
  vpn_gateway_id     = azurerm_vpn_gateway.onpremise.id
  remote_vpn_site_id = azurerm_vpn_site.onpremise.id

  vpn_link {
    name             = "onpremise-connection"
    vpn_site_link_id = azurerm_vpn_site.onpremise.link[0].id
    protocol         = "IKEv2"
    shared_key       = random_string.psk.result
  }
}

resource "azurerm_virtual_hub_connection" "hub_to_vnet" {
  name                      = "hub-to-vnet-connection"
  virtual_hub_id            = azurerm_virtual_hub.this.id
  remote_virtual_network_id = var.core_services_vnet_id
}