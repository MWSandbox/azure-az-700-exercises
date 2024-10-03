locals {
  backend_count     = 2
  backend_locations = ["germanywestcentral", "westeurope"]
}

resource "azurerm_resource_group" "contoso" {
  name     = "ContosoResourceGroup"
  location = var.location
}

module "web_app" {
  count = local.backend_count

  source = "../web-application"

  resource_group   = azurerm_resource_group.contoso.name
  location         = local.backend_locations[count.index]
  name             = "mdevoc-backend-${count.index}"
  service_plan_sku = "S1"
}

resource "azurerm_traffic_manager_profile" "this" {
  name                   = "gateway"
  resource_group_name    = azurerm_resource_group.contoso.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "mdevoc"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 10
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "backend" {
  count = local.backend_count

  name               = "backend-${count.index}"
  profile_id         = azurerm_traffic_manager_profile.this.id
  target_resource_id = module.web_app[count.index].id
  priority           = count.index + 1
}