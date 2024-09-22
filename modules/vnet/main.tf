resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.cidr]

  dynamic "subnet" {
    for_each = toset(var.subnets)

    content {
      name           = subnet.value.name
      address_prefix = subnet.value.cidr
    }
  }
}