locals {
  ip_addresses = flatten([for cp in var.control_plane : cp.ip_addresses])
  external_api_address = coalesce(var.dns_name, var.network.ip)
}
