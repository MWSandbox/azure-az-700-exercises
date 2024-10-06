locals {
  backend_pool_size  = 3
  network_watcher_rg = "NetworkWatcherRG"
}

data "azurerm_network_watcher" "this" {
  name                = var.network_watcher_name
  resource_group_name = local.network_watcher_rg
}

module "backend_vm" {
  count = local.backend_pool_size

  source = "../windows-vm"

  resource_group             = var.resource_group
  name                       = "backend-${count.index}"
  subnet                     = "SharedServicesSubnet"
  vnet                       = var.core_services_vnet_name
  username                   = var.username
  vm_size                    = "Standard_DS1_v2"
  is_public                  = false
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}

resource "azurerm_public_ip" "load_balancer" {
  name                = "load-balancer"
  location            = var.core_services_vnet_location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}


module "load_balancer" {
  source = "../load-balancer"

  resource_group  = var.resource_group
  subnet_id       = var.shared_services_subnet_id
  location        = var.core_services_vnet_location
  backend_nic_ids = [for vm in module.backend_vm : vm.nic_id]
}

module "bastion" {
  source = "../bastion"

  resource_group             = var.resource_group
  location                   = var.core_services_vnet_location
  subnet_id                  = var.bastion_subnet_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}

module "caller_vm" {
  source = "../windows-vm"

  resource_group             = var.resource_group
  name                       = "caller-dummy"
  subnet                     = "SharedServicesSubnet"
  vnet                       = var.core_services_vnet_name
  username                   = var.username
  vm_size                    = "Standard_DS1_v2"
  is_public                  = false
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}


resource "azurerm_log_analytics_workspace" "this" {
  name                = "network-analytics"
  location            = var.core_services_vnet_location
  resource_group_name = var.resource_group
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

data "azurerm_monitor_diagnostic_categories" "load_balancer" {
  resource_id = module.load_balancer.id
}

resource "azurerm_monitor_diagnostic_setting" "load_balancer" {
  name                       = "load-balancer"
  target_resource_id         = module.load_balancer.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  dynamic "enabled_log" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.load_balancer.log_category_types
    content {
      category = entry.value
    }
  }

  dynamic "metric" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.load_balancer.metrics
    content {
      category = entry.value
    }
  }
}

resource "azurerm_storage_account" "flow_logs" {
  name                     = "mdevocflowlogs"
  resource_group_name      = var.resource_group
  location                 = var.core_services_vnet_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_network_watcher_flow_log" "nsg" {
  for_each = var.nsg_name_to_id

  network_watcher_name = var.network_watcher_name
  resource_group_name  = local.network_watcher_rg
  name                 = each.key

  network_security_group_id = each.value
  storage_account_id        = azurerm_storage_account.flow_logs.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.this.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.this.location
    workspace_resource_id = azurerm_log_analytics_workspace.this.id
    interval_in_minutes   = 10
  }
}

resource "azurerm_network_connection_monitor" "backend_pool" {
  name               = "backend-pool-internet-connectivity"
  network_watcher_id = data.azurerm_network_watcher.this.id
  location           = data.azurerm_network_watcher.this.location

  endpoint {
    name               = "source"
    target_resource_id = module.backend_vm[0].id
  }

  endpoint {
    name    = "destination"
    address = "www.google.com"
  }

  test_configuration {
    name                      = "http"
    protocol                  = "Http"
    test_frequency_in_seconds = 60

    http_configuration {
      method                   = "Get"
      port                     = 80
      valid_status_code_ranges = ["2xx"]
    }

    success_threshold {
      checks_failed_percent = 10
      round_trip_time_ms    = 120
    }
  }

  test_group {
    name                     = "test-internet-connectivity"
    destination_endpoints    = ["destination"]
    source_endpoints         = ["source"]
    test_configuration_names = ["http"]
  }

  output_workspace_resource_ids = [azurerm_log_analytics_workspace.this.id]
}