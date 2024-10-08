data "azurerm_virtual_network" "this" {
  name                = var.vnet
  resource_group_name = var.resource_group
}

data "azurerm_subnet" "this" {
  name                 = var.subnet
  virtual_network_name = var.vnet
  resource_group_name  = var.resource_group
}

resource "random_string" "password" {
  length           = 16
  special          = true
  override_special = "!-_."
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
}

resource "azurerm_network_interface" "primary" {
  name                = "${var.name}VM-nic"
  location            = data.azurerm_virtual_network.this.location
  resource_group_name = var.resource_group
  dns_servers         = var.dns_servers

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.is_public ? azurerm_public_ip.this[0].id : null
  }
}

data "azurerm_monitor_diagnostic_categories" "nic" {
  resource_id = azurerm_network_interface.primary.id
}

resource "azurerm_monitor_diagnostic_setting" "nic" {
  count = var.log_analytics_workspace_id == null ? 0 : 1

  name                       = azurerm_network_interface.primary.name
  target_resource_id         = azurerm_network_interface.primary.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.nic.log_category_types
    content {
      category = entry.value
    }
  }

  dynamic "metric" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.nic.metrics
    content {
      category = entry.value
    }
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  name                              = "${var.name}VM"
  resource_group_name               = var.resource_group
  location                          = data.azurerm_virtual_network.this.location
  size                              = var.vm_size
  admin_username                    = var.username
  admin_password                    = random_string.password.result
  network_interface_ids             = [azurerm_network_interface.primary.id]
  availability_set_id               = var.availability_set_id
  vm_agent_platform_updates_enabled = true

  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "this" {
  count = var.is_public ? 1 : 0

  name                = "${var.name}-IP"
  resource_group_name = var.resource_group
  location            = data.azurerm_virtual_network.this.location
  allocation_method   = "Static"
}

resource "azurerm_virtual_machine_extension" "network_watcher" {
  name                       = "network-watcher-extension"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
}