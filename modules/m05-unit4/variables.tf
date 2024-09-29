variable "resource_group" {
  type = string
}

variable "core_services_vnet_name" {
  type = string
}

variable "core_services_vnet_location" {
  type = string
}

variable "shared_services_subnet_id" {
  type = string
}

variable "public_web_services_subnet_id" {
  type = string
}

variable "bastion_subnet_id" {
  type = string
}

variable "username" {
  type = string
}