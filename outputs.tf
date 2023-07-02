output "core_services_vm_password" {
  value = module.core_services_vm.password.result
}

output "manufacturing_vm_password" {
  value = module.manufacturing_vm.password.result
}