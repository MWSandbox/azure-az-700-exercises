variable "resource_group" {
  type = string
}

variable "name" {
  type = string
}

variable "subnet" {
  type = string
}

variable "vnet" {
  type = string
}

variable "username" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "availability_set_id" {
  type    = string
  default = null
}

variable "is_public" {
  type    = bool
  default = true
}
