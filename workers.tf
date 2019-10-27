
resource "libvirt_volume" "worker" {
  count  = 2
  name   = "worker-${count.index}"
  pool   = "default"
  base_volume_id = libvirt_volume.ubuntu.id
  format = "qcow2"
  size   = 8589934592
}

resource "libvirt_domain" "worker" {
  count  = 2
  name   = "worker-${count.index}"
  memory = "1024"
  vcpu   = 2

  disk { volume_id = libvirt_volume.worker[count.index].id }

  network_interface { 
    hostname   = "worker-${count.index}"
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

output "worker_ips" { value = libvirt_domain.worker.*.network_interface.0.addresses.0 }
