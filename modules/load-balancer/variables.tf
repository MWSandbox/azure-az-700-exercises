variable "location" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "backend_nic_ids" {
  type = list(string)
}

variable "public_ip_id" {
  type    = string
  default = null
}