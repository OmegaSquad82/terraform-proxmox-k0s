locals {
  hotplug = concat(["disk", "network", "usb"], var.cpu.numa ? ["memory", "cpu"] : [])
}

resource "proxmox_vm_qemu" "k0s_node" {
  count = var.node_count

  desc = <<-EOT
    <h2>k0s Worker Node</h2>
    <p>
    <strong>Cluster:</strong> ${var.cluster_name}</br>
    <strong>Pool:</strong> ${var.name}</br>
    <strong>Index:</strong> ${count.index}</br>
    </p>
    </hr>
    <em>Managed by Terraform</em>
  EOT

  name = "k0s-${var.cluster_name}-wrk-${var.name}-${count.index}"

  pool        = var.pve.pool
  target_node = var.pve.node
  vmid        = try(var.pve.base_vmid + count.index, null)

  clone                   = var.os.template
  full_clone              = !var.os.linked
  os_type                 = "cloud-init"
  cicustom                = "user=${proxmox_virtual_environment_file.cloud_init[count.index].id}"
  cloudinit_cdrom_storage = var.os.storage.cdrom
  ciuser                  = var.ssh.user
  sshkeys                 = var.ssh.public_key
  bios                    = var.bios
  qemu_os                 = var.qemu_os

  agent = var.agent_enabled ? 1 : 0

  cpu     = var.cpu.type
  cores   = var.cpu.cores
  sockets = var.cpu.sockets
  numa    = var.cpu.numa
  memory  = var.memory.megabytes
  balloon = var.memory.balloon != null ? var.memory.balloon : var.memory.megabytes
  hotplug = join(",", local.hotplug)
  onboot  = true

  vga {
    memory = 0
    type   = "serial0"
  }

  serial {
    id   = 0
    type = "socket"
  }

  ipconfig0 = "ip=${cidrhost(var.network.subnet_cidr, var.network.base_index + count.index)}/${split("/", var.network.cidr)[1]},gw=${var.network.gateway}"

  network {
    model  = var.network.driver
    bridge = var.network.bridge
    tag    = var.network.tag
  }

  scsihw = "virtio-scsi-pci"
  boot   = "c"

  disk {
    size    = var.root_disk.size
    storage = var.root_disk.storage
    type    = "scsi"
    format  = "raw"
    discard = "on"
  }

  dynamic "disk" {
    for_each = var.extra_disks

    content {
      size    = disk.value.size
      storage = disk.value.storage
      type    = "scsi"
      format  = "raw"
      discard = "on"
    }
  }

  lifecycle {
    ignore_changes = [
      pool,
      tags,
    ]
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "sleep $(( $RANDOM % 10 ))s && ssh-keygen -f ${pathexpand("~/.ssh/known_hosts")} -R ${self.default_ipv4_address}"
  }
}
