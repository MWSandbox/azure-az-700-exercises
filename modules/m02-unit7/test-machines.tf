module "onpremise_vm" {
  source = "../windows-vm"

  resource_group = var.resource_group
  name           = "OnPremise"
  subnet         = "ManufacturingSystemSubnet"
  vnet           = var.manufacturing_vnet_name
  username       = var.username
  vm_size        = "Standard_DS1_v2"
}

module "vnet_vm" {
  source = "../windows-vm"

  resource_group = var.resource_group
  name           = "VNet"
  subnet         = "SharedServicesSubnet"
  vnet           = var.core_services_vnet_name
  username       = var.username
  vm_size        = "Standard_DS1_v2"
}