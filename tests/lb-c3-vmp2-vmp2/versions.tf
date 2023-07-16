terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9.10"
    }

    proxmox-resource = {
      source  = "bpg/proxmox"
      version = "~> 0.24.0"
    }
  }
}
