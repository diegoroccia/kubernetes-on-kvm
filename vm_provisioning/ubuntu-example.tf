# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

# We fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "ubuntu-img" {
  name   = "ubuntu-img"
  pool   = "default"
  source = "http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.tar.gz"
  format = "raw"
}

# Create a network for our VMs
resource "libvirt_network" "default" {
  name      = "default"
  addresses = ["192.168.100.0/24"]
  dhcp {
    enabled = true
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
}

# Create the machine
resource "libvirt_domain" "domain-ubuntu" {
  name   = "vm01"
  memory = "512"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "default"
  }

  # IMPORTANT
  # Ubuntu can hang if an isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.ubuntu-img.id
  }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

