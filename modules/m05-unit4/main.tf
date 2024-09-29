locals {
  backend_address_pool_name      = "backend"
  gateway_ip_configuration_name  = "private-ip-config"
  frontend_port_name             = "http"
  frontend_ip_configuration_name = "public-ip-config"
  http_setting_name              = "http-settings"
  listener_name                  = "http-listener"
  request_routing_rule_name      = "http-forwarding"
  redirect_configuration_name    = "redirect-config"
  backend_pool_size              = 2
}

resource "azurerm_public_ip" "application_gateway" {
  name                = "application-gateway"
  resource_group_name = var.resource_group
  location            = var.core_services_vnet_location
  allocation_method   = "Static"
}

resource "azurerm_network_security_rule" "application_gateway" {
  name                        = "allow-application-gateway"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["65200-65535", "80"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = "CoreServicesVnet-PublicWebServiceSubnet-NSG"
}

resource "azurerm_application_gateway" "this" {
  name                = "app-gateway"
  resource_group_name = var.resource_group
  location            = var.core_services_vnet_location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.public_web_services_subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.application_gateway.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 10
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  depends_on = [azurerm_network_security_rule.application_gateway]
}

module "backend_vm" {
  count = local.backend_pool_size

  source = "../windows-vm"

  resource_group = var.resource_group
  name           = "backend-${count.index}"
  subnet         = "SharedServicesSubnet"
  vnet           = var.core_services_vnet_name
  username       = var.username
  vm_size        = "Standard_DS1_v2"
  is_public      = false
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "this" {
  count = local.backend_pool_size

  network_interface_id    = module.backend_vm[count.index].nic_id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = tolist(azurerm_application_gateway.this.backend_address_pool).0.id
}

module "bastion" {
  source = "../bastion"

  resource_group = var.resource_group
  location       = var.core_services_vnet_location
  subnet_id      = var.bastion_subnet_id
}