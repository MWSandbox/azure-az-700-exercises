locals {
  dns_servers = ["209.244.0.3", "209.244.0.4"]
}

data "http" "my_ip" {
  url = "http://icanhazip.com"
}

module "backend_vm" {
  source = "../windows-vm"

  resource_group = var.resource_group
  name           = "backend"
  subnet         = "SharedServicesSubnet"
  vnet           = var.core_services_vnet_name
  username       = var.username
  vm_size        = "Standard_DS1_v2"
  is_public      = false
  dns_servers    = local.dns_servers
}

resource "azurerm_public_ip" "firewall" {
  name                = "firewall-public-ip"
  location            = var.core_services_vnet_location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "this" {
  name                = "firewall"
  location            = var.core_services_vnet_location
  resource_group_name = var.resource_group
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.this.id

  ip_configuration {
    name                 = "ip-config-1"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_route_table" "shared_services" {
  name                = "shared-services"
  location            = var.core_services_vnet_location
  resource_group_name = var.resource_group

  route {
    name                   = "route-through-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.this.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "shared_services" {
  subnet_id      = var.shared_services_subnet_id
  route_table_id = azurerm_route_table.shared_services.id
}

resource "azurerm_firewall_policy" "this" {
  name                = "standard-policy"
  resource_group_name = var.resource_group
  location            = var.core_services_vnet_location
  sku                 = "Standard"
}

resource "azurerm_firewall_policy_rule_collection_group" "vm_connectivity" {
  name               = "vm-connectivity"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 200
  application_rule_collection {
    name     = "allow-google"
    priority = 100
    action   = "Allow"
    rule {
      name = "allow-google"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["10.20.10.0/24"]
      destination_fqdns = ["www.google.com"]
    }
  }
  network_rule_collection {
    name     = "allow-dns"
    priority = 200
    action   = "Allow"
    rule {
      name                  = "allow-dns"
      protocols             = ["UDP"]
      source_addresses      = ["10.20.10.0/24"]
      destination_addresses = local.dns_servers
      destination_ports     = ["53"]
    }
  }

  nat_rule_collection {
    name     = "allow-rdp"
    priority = 300
    action   = "Dnat"
    rule {
      name                = "allow-rdp"
      protocols           = ["TCP"]
      source_addresses    = ["${chomp(data.http.my_ip.response_body)}/32"]
      destination_address = azurerm_public_ip.firewall.ip_address
      destination_ports   = ["3389"]
      translated_address  = module.backend_vm.private_ip
      translated_port     = "3389"
    }
  }
}
