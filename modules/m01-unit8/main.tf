# module "core_services_vm" {
#   source = "./../windows-vm"

#   name = "CoreServices"
#   resource_group = var.resource_group
#   vnet = var.core_services_vnet_name
#   subnet = "DatabaseSubnet"
#   username = var.username
#   vm_size = "Standard_DS1_v2"
# }

# module "manufacturing_vm" {
#   source = "./../windows-vm"

#   name = "Manufacturing"
#   resource_group = var.resource_group
#   vnet = var.manufacturing_vnet_name
#   subnet = "ManufacturingSystemSubnet"
#   username = var.username
#   vm_size = "Standard_DS1_v2"
# }

# resource "azurerm_virtual_network_peering" "core_to_manufacturing" {
#   name                      = "CoreServicesVnet-to-ManufacturingVnet"
#   resource_group_name       = var.resource_group
#   virtual_network_name      = var.core_services_vnet.name
#   remote_virtual_network_id = var.manufacturing_vnet.id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic = true
# }

# resource "azurerm_virtual_network_peering" "manufacturing_to_core" {
#   name                      = "ManufacturingVnet-to-CoreServicesVnet"
#   resource_group_name       = var.resource_group
#   virtual_network_name      = var.manufacturing_vnet.name
#   remote_virtual_network_id = var.core_services_vnet.id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic = true
# }