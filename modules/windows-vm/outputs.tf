output "password" {
  value = random_string.password.result
}

output "nic_id" {
  value = azurerm_network_interface.primary.id
}

output "id" {
  value = azurerm_windows_virtual_machine.this.id
}

output "private_ip" {
  value = azurerm_network_interface.primary.ip_configuration[0].private_ip_address
}