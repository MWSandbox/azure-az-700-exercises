data "http" "my_ip" {
  url = "http://icanhazip.com"
}

locals {
  nsg_relevant_subnets = { for key, value in var.subnets : key => value if !contains(["GatewaySubnet", "AzureBastionSubnet", "AzureFirewallSubnet"], key) }
}

resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.cidr]
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}

resource "azurerm_network_security_group" "this" {
  for_each = local.nsg_relevant_subnets

  name                = "${var.name}-${each.key}-NSG"
  location            = azurerm_virtual_network.this.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "subnet" {
  for_each = local.nsg_relevant_subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

resource "azurerm_network_security_rule" "rdp" {
  for_each = local.nsg_relevant_subnets

  name                        = "default-allow-rdp"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "${chomp(data.http.my_ip.response_body)}/32"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[each.key].name
}