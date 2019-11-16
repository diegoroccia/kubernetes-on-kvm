
output "ip" { value = libvirt_domain.master.network_interface.0.addresses.0 }
