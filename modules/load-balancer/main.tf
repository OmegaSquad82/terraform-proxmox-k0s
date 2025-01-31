resource "proxmox_lxc" "load_balancer" {
  description = <<-EOT
    <h2>k0s Control Plane Load Balancer</h2>
    <p>
    <strong>Cluster:</strong> ${var.cluster_name}</br>
    ${var.stats.enabled ? "<strong><a href=\"http://${local.external_api_address}:9000/\" target=\"_blank\">Proxy Stats</a></strong>" : ""}
    </p>
    </hr>
    <em>Managed by Terraform</em>
  EOT

  hostname = "k0s-${var.cluster_name}-lb"

  ostemplate   = var.os.template
  full         = !var.os.linked
  ostype       = var.os.type
  unprivileged = true

  pool        = var.pve.pool
  target_node = var.pve.node
  vmid        = var.pve.vmid
  hastate     = var.ha.state
  hagroup     = var.ha.group

  cores    = var.cpu.cores
  cpulimit = var.cpu.limit != null ? var.cpu.limit : var.cpu.cores
  cpuunits = var.cpu.units
  memory   = var.memory.megabytes
  swap     = var.memory.swap

  start  = true
  onboot = true
  # startup = "order=${var.vmid}"

  password        = random_password.user_password.result
  ssh_public_keys = var.ssh.public_key

  rootfs {
    storage = var.root_disk.storage
    size    = var.root_disk.size
  }

  network {
    name   = var.network.name
    bridge = var.network.bridge
    ip     = "${var.network.ip}/${split("/", var.network.cidr)[1]}"
    gw     = var.network.gateway
    tag    = var.network.tag
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get install -y haproxy",
    ]

    connection {
      host        = var.network.ip
      type        = "ssh"
      user        = var.ssh.user
      private_key = var.ssh.private_key
      #password    = random_password.user_password.result # Fallback is private key not specified
    }
  }

  provisioner "file" {
    destination = "/etc/haproxy/haproxy.cfg"
    content = templatefile("${path.module}/templates/haproxy.cfg.tftpl", {
      ip_addrs = local.ip_addresses
      stats    = var.stats
    })

    connection {
      host        = var.network.ip
      type        = "ssh"
      user        = var.ssh.user
      private_key = var.ssh.private_key
      #password    = random_password.user_password.result # Fallback is private key not specified
    }
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl enable haproxy.service",
      "systemctl restart haproxy.service",
    ]

    connection {
      host        = var.network.ip
      type        = "ssh"
      user        = var.ssh.user
      private_key = var.ssh.private_key
      #password    = random_password.user_password.result # Fallback is private key not specified
    }
  }

  lifecycle {
    ignore_changes = [
      target_node,
    ]
  }
}

resource "random_password" "user_password" {
  length           = 32
  special          = true
  override_special = "!@#$%&*-_=+"
}
