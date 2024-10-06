resource "azurerm_public_ip" "bastion" {
  name                = "bastion"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "this" {
  name                = "bastion"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                 = "public-ip"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

data "azurerm_monitor_diagnostic_categories" "public_ip" {
  resource_id = azurerm_public_ip.bastion.id
}

resource "azurerm_monitor_diagnostic_setting" "public_ip" {
  count = var.log_analytics_workspace_id == null ? 0 : 1

  name                       = "bastion_public_ip"
  target_resource_id         = azurerm_public_ip.bastion.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.public_ip.log_category_types
    content {
      category = entry.value
    }
  }

  dynamic "metric" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.public_ip.metrics
    content {
      category = entry.value
    }
  }
}

data "azurerm_monitor_diagnostic_categories" "bastion" {
  resource_id = azurerm_bastion_host.this.id
}

resource "azurerm_monitor_diagnostic_setting" "bastion" {
  count = var.log_analytics_workspace_id == null ? 0 : 1

  name                       = "bastion"
  target_resource_id         = azurerm_bastion_host.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.bastion.log_category_types
    content {
      category = entry.value
    }
  }

  dynamic "metric" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.bastion.metrics
    content {
      category = entry.value
    }
  }
}