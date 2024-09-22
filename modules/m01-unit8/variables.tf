variable "resource_group" {
  type = string
}

variable "core_services_vnet" {
  type = object({
    id       = string
    name     = string
    location = string
  })
}

variable "manufacturing_vnet" {
  type = object({
    id       = string
    name     = string
    location = string
  })
}
