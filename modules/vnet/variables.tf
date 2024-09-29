variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "cidr" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnets" {
  type = map(string)
}