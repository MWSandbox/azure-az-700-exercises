locals {
  backend_pool_size = 2
}

resource "azurerm_availability_set" "backend_pool" {
  name                = "backend-pool"
  location            = var.core_services_vnet_location
  resource_group_name = var.resource_group
}

module "backend_vm" {
  count = local.backend_pool_size

  source = "../windows-vm"

  resource_group      = var.resource_group
  name                = "backend-${count.index}"
  subnet              = "SharedServicesSubnet"
  vnet                = var.core_services_vnet_name
  username            = var.username
  vm_size             = "Standard_DS1_v2"
  is_public           = false
  availability_set_id = azurerm_availability_set.backend_pool.id
}

resource "azurerm_lb" "this" {
  name                = "backend-pool-lb"
  location            = var.core_services_vnet_location
  resource_group_name = var.resource_group

  frontend_ip_configuration {
    name                          = "private-ip"
    subnet_id                     = var.shared_services_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "backend" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "backend"
}

resource "azurerm_network_interface_backend_address_pool_association" "backend" {
  count = local.backend_pool_size

  network_interface_id    = module.backend_vm[count.index].nic_id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
}

resource "azurerm_lb_probe" "tcp" {
  name            = "tcp-probe"
  protocol        = "Tcp"
  port            = 80
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_lb_rule" "this" {
  loadbalancer_id                = azurerm_lb.this.id
  name                           = "backend-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.this.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend.id]
  probe_id                       = azurerm_lb_probe.tcp.id
}

module "caller_vm" {
  source = "../windows-vm"

  resource_group = var.resource_group
  name           = "caller-dummy"
  subnet         = "SharedServicesSubnet"
  vnet           = var.core_services_vnet_name
  username       = var.username
  vm_size        = "Standard_DS1_v2"
  is_public      = false
}

module "bastion" {
  source = "../bastion"

  resource_group = var.resource_group
  location       = var.core_services_vnet_location
  subnet_id      = var.bastion_subnet_id
}