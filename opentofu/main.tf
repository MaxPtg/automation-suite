locals {
  templates = {
    debian = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    ubuntu = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  }
}

resource "proxmox_lxc" "container" {
  target_node = "pve"
  hostname    = var.hostname
  ostemplate  = local.templates[var.os_type]
  vmid        = var.container_id
  
  // Unprivileged container configuration
  unprivileged = var.docker_enabled ? false : true
  
  // Features
  features {
    nesting = true
    keyctl  = var.docker_enabled
    fuse    = var.docker_enabled
  }
  
  // Resources
  cores  = var.cores
  memory = var.memory
  swap   = var.swap
  
  // Storage
  rootfs {
    storage = "local-lvm"
    size    = "${var.storage_size}G"
  }
  
  // Network configuration
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.178.${var.container_id}/24"
    gw     = "192.168.178.1"
  }
  
  // DNS configuration
  nameserver = "192.168.178.1"
  searchdomain = "homelab.local"
  
  // Start on creation
  start = true
  
  // Default password
  password = "Asdf1234#"
}