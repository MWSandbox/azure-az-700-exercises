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