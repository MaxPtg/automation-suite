variable "pm_api_token_secret" {
  type = string
  sensitive = true
  description = "Proxmox API token secret"
}

variable "container_id" {
  type = number
  description = "Container ID (200-254)"
  validation {
    condition = var.container_id >= 200 && var.container_id <= 254
    error_message = "Container ID must be between 200 and 254."
  }
}

variable "hostname" {
  type = string
  description = "Container hostname"
}

variable "os_type" {
  type = string
  description = "OS type (debian or ubuntu)"
  validation {
    condition = contains(["debian", "ubuntu"], var.os_type)
    error_message = "OS type must be either 'debian' or 'ubuntu'."
  }
}

variable "docker_enabled" {
  type = bool
  default = false
  description = "Enable Docker support in container"
}

# Storage configuration
variable "storage_size" {
  type = number
  default = 10
  description = "Storage size in GB"
}

# Resource configuration
variable "cores" {
  type = number
  default = 2
}

variable "memory" {
  type = number
  default = 1024
}

variable "swap" {
  type = number
  default = 512
}
