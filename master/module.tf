
module "cloud_init" {
  source   = "../cloud_init"
  hostname = var.hostname
}

resource "libvirt_volume" "master" {
  name   = var.hostname
  pool   = "default"
  base_volume_id = var.base_volume_id
  format = "qcow2"
  size   = 4294967296
}

resource "libvirt_domain" "master" {
  name   = var.hostname 
  memory = "1024"
  vcpu   = 2

  disk { volume_id = libvirt_volume.master.id }

  network_interface { 
    network_id = var.network_id
    wait_for_lease = true
  }

  cloudinit = module.cloud_init.disk_id

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

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

}

