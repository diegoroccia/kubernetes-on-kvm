variable "hostname" { type = string }

data "template_file" "user_data" { 
  template = file("${path.module}/cloud_init.cfg") 
  vars = {
    hostname = var.hostname
  }
}

data "template_file" "network_config" { template = file("${path.module}/network_config.cfg") }

resource "libvirt_cloudinit_disk" "cloudinit" {
  name           = "cloudinit_${var.hostname}.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
}

output "disk_id" { value = libvirt_cloudinit_disk.cloudinit.id }
