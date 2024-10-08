data "http" "my_ip" {
  url = "http://icanhazip.com"
}

resource "azurerm_storage_account" "this" {
  name                     = "mdevoctest"
  resource_group_name      = var.resource_group
  location                 = var.core_services_vnet_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.service_endpoint.id]
    ip_rules                   = ["${chomp(data.http.my_ip.response_body)}/30"]
  }
}

resource "azurerm_storage_share" "this" {
  name                 = "test"
  storage_account_name = azurerm_storage_account.this.name
  access_tier          = "Hot"
  quota                = 1
}

module "caller_vm" {
  source = "../windows-vm"

  resource_group = var.resource_group
  name           = "caller-dummy"
  subnet         = azurerm_subnet.service_endpoint.name
  vnet           = var.core_services_vnet_name
  username       = var.username
  vm_size        = "Standard_DS1_v2"
  is_public      = true
}

resource "azurerm_subnet" "service_endpoint" {
  name                 = "service-endpoint-subnet"
  resource_group_name  = var.resource_group
  virtual_network_name = var.core_services_vnet_name
  address_prefixes     = ["10.20.100.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_network_security_group" "service_endpoint" {
  name                = "service-endpoint-NSG"
  location            = var.core_services_vnet_location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet_network_security_group_association" "service_endpoint" {
  subnet_id                 = azurerm_subnet.service_endpoint.id
  network_security_group_id = azurerm_network_security_group.service_endpoint.id
}

resource "azurerm_network_security_rule" "allow_storage_outbound" {
  name                        = "allow-storage-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "*"
  destination_address_prefix  = "Storage"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.service_endpoint.name
}

resource "azurerm_network_security_rule" "allow_rdp_inbound" {
  name                        = "allow-rdp-inbound"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "${chomp(data.http.my_ip.response_body)}/32"
  destination_port_range      = "3389"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.service_endpoint.name
}

resource "azurerm_network_security_rule" "deny_internet_outbound" {
  name                        = "deny-internet-outbound"
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.service_endpoint.name
}