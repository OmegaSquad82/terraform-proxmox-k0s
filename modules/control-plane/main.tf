resource "proxmox_lxc" "controller" {
  count = var.node_count

  description = <<-EOT
    <h2>k0s Controller Node</h2>
    <p>
    <strong>Cluster:</strong> ${var.cluster_name}</br>
    <strong>Index:</strong> ${count.index}</br>
    </p>
    </hr>
    <em>Managed by Terraform</em>
  EOT

  hostname = "k0s-${var.cluster_name}-ctl${var.name == null ? "" : "-${var.name}"}-${count.index}"

  ostemplate   = var.os.template
  full         = !var.os.linked
  ostype       = var.os.type
  unprivileged = true

  pool        = var.pve.pool
  target_node = var.pve.node
  vmid        = try(var.pve.base_vmid + count.index, null)
  hastate     = var.ha.state
  hagroup     = var.ha.group

  cores    = var.cpu.cores
  cpulimit = var.cpu.limit != null ? var.cpu.limit : var.cpu.cores
  cpuunits = var.cpu.units
  memory   = var.memory.megabytes
  swap     = var.memory.swap

  start  = true
  onboot = true
  # startup = "order=${var.base_vmid + min(1, count.index)}"

  password        = random_password.root_password[count.index].result
  ssh_public_keys = var.ssh.public_key

  rootfs {
    storage = var.root_disk.storage
    size    = var.root_disk.size
  }

  network {
    name   = var.network.name
    bridge = var.network.bridge
    ip     = "${cidrhost(var.network.subnet_cidr, var.network.base_index + count.index)}/${split("/", var.network.cidr)[1]}"
    gw     = var.network.gateway
    tag    = var.network.tag
  }

  lifecycle {
    ignore_changes = [
      target_node,
    ]
  }

  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "ssh-keygen -f ${pathexpand("~/.ssh/known_hosts")} -R ${split("/", self.network[0].ip)[0]}"
  }
}

resource "random_password" "root_password" {
  count = var.node_count

  length           = 32
  special          = true
  override_special = "!@#$%&*-_=+"
}
