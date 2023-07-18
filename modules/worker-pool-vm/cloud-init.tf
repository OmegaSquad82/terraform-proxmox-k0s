resource "proxmox_virtual_environment_file" "cloud_init" {
  count    = var.node_count
  provider = proxmox-resource

  content_type = "snippets"
  datastore_id = var.os.storage.snippet
  node_name    = var.pve.node

  source_raw {
    file_name = "k0s-${var.cluster_name}-wrk-${var.name}-${count.index}-cloud-init.yaml"
    data = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
      hostname    = "k0s-${var.cluster_name}-wrk-${var.name}-${count.index}"
      upgrade     = var.os.upgrade
      packages    = var.os.packages
      ssh_user    = var.ssh.user
      ssh_key     = var.ssh.public_key
      extra_disks = var.extra_disks
    })
  }
}
