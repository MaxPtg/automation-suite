output "container_ip" {
  value = proxmox_lxc.container.network[0].ip
}

output "container_id" {
  value = proxmox_lxc.container.vmid
}

output "container_hostname" {
  value = proxmox_lxc.container.hostname
}

output "container_unprivileged" {
  value = proxmox_lxc.container.unprivileged
}
