variable "resource_group" {
  type = string
}

variable "core_services_vnet_name" {
  type = string
}

variable "core_services_vnet_location" {
  type = string
}

variable "manufacturing_vnet_name" {
  type = string
}

variable "manufacturing_vnet_location" {
  type = string
}

variable "username" {
  type = string
}

variable "is_vnet_gateway_enabled" {
  default = false
  type    = bool
}