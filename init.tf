resource "libvirt_volume" "ubuntu-bionic" {
  name   = "ubuntu"
  pool   = "default"
  source = "${path.module}/bionic-server-cloudimg-amd64.img"
  format = "qcow2"
}

module "master" {
  source = "./master"
  hostname = "master01.local"
  base_volume_id = libvirt_volume.ubuntu-bionic.id
  network_id = libvirt_network.default.id 
}

module "worker" {
  source = "./worker"
  hostname = "worker01.local"
  base_volume_id = libvirt_volume.ubuntu-bionic.id
  network_id = libvirt_network.default.id 
}

output "master_ip" { value = module.master.ip }
output "worker_ip" { value = module.worker.ip }
