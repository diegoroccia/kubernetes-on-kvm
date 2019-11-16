
output "ip" { value = libvirt_domain.worker.network_interface.0.addresses.0 }
