output "password" {
  value = random_string.password.result
}

output "nic_id" {
  value = azurerm_network_interface.primary.id
}