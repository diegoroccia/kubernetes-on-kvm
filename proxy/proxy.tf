resource "libvirt_volume" "proxy" {
  name   = "proxy"
  pool   = "default"
  base_volume_id = libvirt_volume.ubuntu.id
  format = "qcow2"
}

data "template_file" "user_data_proxy" { 
  template = templatefile("${path.module}/cloud_init_proxy.cfg", { "port" = 6443, "masters" = libvirt_domain.master.*.network_interface.0.addresses.0 })
  depends_on = [libvirt_domain.master]
}

resource "libvirt_cloudinit_disk" "proxyinit" {
  name           = "proxyinit.iso"
  user_data      = data.template_file.user_data_proxy.rendered
  network_config = data.template_file.network_config.rendered
}

resource "libvirt_domain" "proxy" {
  name   = "proxy"
  memory = "1024"
  vcpu   = 1

  disk { volume_id = libvirt_volume.proxy.id }

  network_interface { 
    hostname = "proxy"
    network_id = libvirt_network.default.id 
    wait_for_lease = true
  }

  cloudinit = libvirt_cloudinit_disk.proxyinit.id

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

output "proxy_ip" { value = libvirt_domain.proxy.network_interface.0.addresses.0 }
