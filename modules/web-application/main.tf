resource "azurerm_service_plan" "this" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.service_plan_sku
}

resource "azurerm_linux_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id

  site_config {}
}