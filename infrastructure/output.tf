output "vm-public-ip" {
  value       = azurerm_public_ip.vm_publicIP.ip_address
  description = "the IP for the application VM"
}
// application vm IP
output "vm_private_ip" {
  value       = azurerm_network_interface.db-nic.private_ip_address
  description = "The private IP address of the VM"
}
// rg name
output "rg" {
  value = azurerm_resource_group.rg.name
}
// VM USER
output "VM_USER" {
  value = var.VM_USER
}
//db vm name
output "db-vm-name" {
  value = azurerm_linux_virtual_machine.db-vm.name
}
//bastion name
output "bastion-name" {
  value = azurerm_bastion_host.bastion.name
}
// bastion dns
output "bastion-host" {
  value = azurerm_bastion_host.bastion.dns_name
}
