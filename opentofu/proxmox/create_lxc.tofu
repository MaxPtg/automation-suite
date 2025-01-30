terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.14"  # Use the latest version available
    }
  }
}

provider "proxmox" {
  pm_api_url = env("PM_API_URL")
  pm_api_token_id = env("PM_API_TOKEN_ID")
  pm_api_token_secret = env("PM_API_TOKEN_SECRET")
  pm_tls_insecure = true  # Set to false in production
}

# Input Variables
variable "container_id" {
  description = "ID for the container (200-254)"
  type = number

  validation {
    condition = var.container_id >= 200 && var.container_id <= 254
    error_message = "Container ID must be between 200 and 254"
  }
}

variable "os_type" {
  description = "OS type (debian or ubuntu)"
  type = string

  validation {
    condition = contains(["debian", "ubuntu"], var.os_type)
    error_message = "OS type must be either debian or ubuntu"
  }
}

variable "hostname" {
  description = "Hostname for the container"
  type = string
}

variable "docker_enabled" {
  description = "Whether to enable Docker support"
  type = bool
  default = false
}

# Local variables for template selection
locals {
  template = var.os_type == "debian" ? env("PM_DEBIAN_TEMPLATE") : env("PM_UBUNTU_TEMPLATE")
  features = var.docker_enabled ? "nesting=1,keyctl=1,fuse=1" : "nesting=1"
  unprivileged = var.docker_enabled ? false : tobool(env("PM_UNPRIVILEGED"))
}

# LXC Container Resource
resource "proxmox_lxc" "container" {
  target_node = env("PM_NODE")
  vmid = var.container_id
  hostname = var.hostname
  ostemplate = "${env("PM_STORAGE_NAME")}:vztmpl/${local.template}"
  password = env("PM_CONTAINER_PASSWORD")
  unprivileged = local.unprivileged
  features {
    nesting = true
    keyctl = var.docker_enabled
    fuse = var.docker_enabled
  }

  // Root disk
  rootfs {
    storage = env("PM_STORAGE_POOL")
    size = "${env("PM_DISK_SIZE")}G"
  }

  // Resources
  cores = tonumber(env("PM_CORES"))
  memory = tonumber(env("PM_MEMORY"))
  swap = tonumber(env("PM_SWAP"))

  // Network configuration
  network {
    name = "eth0"
    bridge = env("PM_NETWORK_BRIDGE")
    firewall = tobool(env("PM_NETWORK_FIREWALL"))
    ip = "192.168.178.${var.container_id}/24"
    gw = env("PM_IPV4_GATEWAY")
  }

  // DNS settings
  nameserver = env("PM_IPV4_GATEWAY")
  searchdomain = env("PM_DNS_DOMAIN")

  // Start on creation
  start = true
}

# Outputs
output "container_id" {
  value = proxmox_lxc.container.vmid
}

output "container_ip" {
  value = proxmox_lxc.container.network[0].ip
}

output "container_status" {
  value = proxmox_lxc.container.status
}
