
resource "libvirt_volume" "ubuntu" {
  name   = "ubuntu"
  pool   = "default"
  source = "${path.module}/bionic-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "master" {
  count  = 2
  name   = "master-${count.index}"
  pool   = "default"
  base_volume_id = libvirt_volume.ubuntu.id
  format = "qcow2"
  size   = 8589934592
}

resource "libvirt_domain" "master" {
  count  = 2
  name   = "master-${count.index}"
  memory = "1024"
  vcpu   = 2

  disk { volume_id = libvirt_volume.master[count.index].id }

  network_interface { 
    hostname   = "master-${count.index}"
    network_id = libvirt_network.default.id 
    wait_for_lease = true
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

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

output "master_ips" { value = libvirt_domain.master.*.network_interface.0.addresses.0 }
