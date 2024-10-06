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

module "load_balancer" {
  source = "../load-balancer"

  resource_group  = var.resource_group
  subnet_id       = var.shared_services_subnet_id
  location        = var.core_services_vnet_location
  backend_nic_ids = [for vm in module.backend_vm : vm.nic_id]
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