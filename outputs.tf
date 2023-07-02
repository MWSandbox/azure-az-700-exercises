output "core_services_vm_password" {
  value = contains(var.module_list, "M02-Unit3") ? module.m02_unit3[0].core_services_vm_password : ""
}

output "manufacturing_vm_password" {
  value = contains(var.module_list, "M02-Unit3") ? module.m02_unit3[0].manufacturing_vm_password : ""
}