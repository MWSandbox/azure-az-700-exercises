resource "azurerm_public_ip" "bastion" {
  name                = "bastion"
  location            = var.core_services_vnet_location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "this" {
  name                = "bastion"
  location            = var.core_services_vnet_location
  resource_group_name = var.resource_group

  ip_configuration {
    name                 = "public-ip"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
