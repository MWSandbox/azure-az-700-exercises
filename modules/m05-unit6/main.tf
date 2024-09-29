locals {
  frontend_endpoint       = "http-endpoint"
  backend_pool_name       = "backend"
  load_balancing_settings = "lb-settings"
  health_probe_settings   = "health-probe-settings"
}

resource "azurerm_frontdoor" "this" {
  name                = "mdevoc"
  resource_group_name = var.resource_group

  routing_rule {
    name               = "http-forwarding"
    accepted_protocols = ["Http"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [local.frontend_endpoint]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = local.backend_pool_name
    }
  }

  backend_pool_load_balancing {
    name = local.load_balancing_settings
  }

  backend_pool_health_probe {
    name = local.health_probe_settings
  }

  backend_pool {
    name = local.backend_pool_name
    backend {
      host_header = var.application_gateway_ip
      address     = var.application_gateway_ip
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = local.load_balancing_settings
    health_probe_name   = local.health_probe_settings
  }

  frontend_endpoint {
    name      = local.frontend_endpoint
    host_name = "mdevoc.azurefd.net"
  }
}