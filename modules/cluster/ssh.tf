resource "local_sensitive_file" "controller_ssh_pk" {
  content              = var.ssh.controller.private_key
  filename             = "${var.local_storage}/controller.pk"
  file_permission      = "0600"
  directory_permission = "0600"
}

resource "local_sensitive_file" "worker_ssh_pk" {
  content              = var.ssh.worker.private_key
  filename             = "${var.local_storage}/worker.pk"
  file_permission      = "0600"
  directory_permission = "0600"
}
