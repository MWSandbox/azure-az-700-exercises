output "name" {
  value = azurerm_virtual_network.this.name
}

output "location" {
  value = azurerm_virtual_network.this.location
}

output "id" {
  value = azurerm_virtual_network.this.id
}

output "subnets" {
  value = { for key, value in azurerm_subnet.this : key => value.id }
}

output "nsg_name_to_id" {
  value = { for key, value in azurerm_network_security_group.this : value.name => value.id }
}