output "application_gateway_ip" {
  value = azurerm_public_ip.application_gateway.ip_address
}