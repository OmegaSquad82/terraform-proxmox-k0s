terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }

    proxmox-resource = {
      source = "bpg/proxmox"
    }
  }

  required_version = ">= 1.3.0"
}
