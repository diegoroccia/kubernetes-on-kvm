
# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

# Create a network for our VMs
resource "libvirt_network" "default" {
  name      = "default"
  addresses = ["192.168.100.0/24"]
  dhcp { enabled = true }
  dns { enabled = true }
}
