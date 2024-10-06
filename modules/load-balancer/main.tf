locals {
  backend_pool_size = 3
}

resource "azurerm_lb" "this" {
  name                = "backend-pool-lb"
  location            = var.location
  resource_group_name = var.resource_group

  dynamic "frontend_ip_configuration" {
    for_each = var.public_ip_id == null ? [var.subnet_id] : []

    content {
      name                          = "private-ip"
      subnet_id                     = var.subnet_id
      private_ip_address_allocation = "Dynamic"
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.public_ip_id == null ? [] : [var.public_ip_id]

    content {
      name                 = "public-ip"
      public_ip_address_id = var.public_ip_id
    }
  }
}

resource "azurerm_lb_backend_address_pool" "backend" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "backend"
}

resource "azurerm_network_interface_backend_address_pool_association" "backend" {
  for_each = { for index, nic in var.backend_nic_ids : index => nic }

  network_interface_id    = each.value
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
}

resource "azurerm_lb_probe" "tcp" {
  name            = "tcp-probe"
  protocol        = "Tcp"
  port            = 80
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_lb_rule" "this" {
  loadbalancer_id                = azurerm_lb.this.id
  name                           = "backend-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.this.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend.id]
  probe_id                       = azurerm_lb_probe.tcp.id
}
