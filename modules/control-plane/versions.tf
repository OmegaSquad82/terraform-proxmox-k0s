terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }

    random = {
      source = "hashicorp/random"
    }
  }

  required_version = ">= 1.3.0"
}
