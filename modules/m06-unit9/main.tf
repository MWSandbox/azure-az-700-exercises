locals {
  wan_location = "germanywestcentral"
}

# resource "azurerm_public_ip" "firewall" {
#   name                = "firewall-public-ip"
#   location            = "germanywestcentral"
#   resource_group_name = var.resource_group
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

resource "azurerm_firewall" "this" {
  name                = "wan-firewall"
  location            = local.wan_location
  resource_group_name = var.resource_group
  sku_name            = "AZFW_Hub"
  sku_tier            = "Standard"

  virtual_hub {
    virtual_hub_id  = azurerm_virtual_hub.this.id
    public_ip_count = 1
  }
}

module "core_services_vm" {
  source = "../windows-vm"

  resource_group = var.resource_group
  name           = "core-services"
  subnet         = "SharedServicesSubnet"
  vnet           = var.core_services_vnet_name
  username       = var.username
  vm_size        = "Standard_DS1_v2"
  is_public      = false
}

module "manufacturing_vm" {
  source = "../windows-vm"

  resource_group = var.resource_group
  name           = "manufacturing"
  subnet         = "ManufacturingSystemSubnet"
  vnet           = var.manufacturing_vnet_name
  username       = var.username
  vm_size        = "Standard_DS1_v2"
  is_public      = false
}
