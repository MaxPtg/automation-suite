output "container_ip" {
  value = proxmox_lxc.container.network[0].ip
}

output "container_id" {
  value = proxmox_lxc.container.vmid
}

output "container_status" {
  value = proxmox_lxc.container.status
}
