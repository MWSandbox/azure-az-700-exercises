variable "username" {
  type = string
}

variable "module_list" {
  type        = list(string)
  default     = ["M01-Unit4", "M06-Unit9"]
  description = "List of modules from the exercises to rollout. M01-Unit4 needs to be always there."
}