variable "cluster_name" {
  description = "The name of the k0s cluster; informational; used in proxmox resources and VM hostnames"

  type    = string
  default = "default"
}

variable "pve" {
  description = <<-EOT
  Proxmox cluster configuration.
  See the proxmox documentation for more information.

  * node - The name of the proxmox node to deploy VMs on
  * pool - The name proxmox resource pool to create resources in; optional
  * base_vmid - The first VMID used when not letting proxmox allocate VMIDs automatically; optional
  EOT

  type = object({
    node = string
    pool = optional(string)
    vmid = optional(number)
  })
}

variable "os" {
  description = <<-EOT
  The VM operating system configuration.
  See the proxmox documentation for more information.

  * template - The container template to clone
  * linked - Whether to create a linked clone; default true
  * type - The OS type, when autodetection fails; default unspecified
  EOT

  type = object({
    template = string
    linked   = optional(bool, true)
    type     = optional(string)
  })
}

variable "ssh" {
  description = <<-EOT
  The SSH connection information for the VMs. This is used by k0sctl in the cluster module.
  If used, the cluster-ssh module can be supplied since it's outputs conform to the object type.

  * user - The SSH user on the VM
  * public_key - The SSH public key to install on the VM
  EOT
  type = object({
    user        = string
    public_key  = string
    private_key = optional(string)
  })
}

variable "cpu" {
  description = <<-EOT
  The CPU configuration for each VM.
  See the proxmox documentation for more information.

  * cores - The number of cores to allocate; default 2
  * limit - The CPU (core) limit for the VM; optional
  * units - The core weight for the VM; optional
  EOT

  type = object({
    cores = number
    limit = optional(number)
    units = optional(number, 1024)
  })

  default = {
    cores = 2
  }
}

variable "memory" {
  description = <<-EOT
  The memory configuration for each VM.
  See the proxmox documentation for more information.

  * megabytes - Pretty obvious; default 256 MB
  * swap - How much swap space to allocate; default 128 MB
  EOT

  type = object({
    megabytes = number
    swap      = optional(number, 128)
  })

  default = {
    megabytes = 256
  }
}

variable "network" {
  description = <<-EOT
  The network configuration for each VM.
  See the proxmox documentation for more information.

  * name - The name of the ethernet device in the VM; default "eth0"
  * bridge - The name of the proxmox bridge to attach the device to
  * cidr - The CIDR block of the network the device is attached to
  * subnet_cidr - The CIDR block for allocating IP addresses for each VM
  * base_index - The index into the CIDR block to allocate to first VM; increments to node_count; default 0
  * gateway - The gateway IP on the network
  * tag - The VLAN tag for this interface
  EOT

  type = object({
    name    = optional(string, "eth0")
    bridge  = string
    cidr    = string
    ip      = string
    gateway = string
    tag     = optional(number)
  })
}

variable "root_disk" {
  description = <<-EOT
  The root disk configuration for each VM
  See the proxmox documentation for more information.

  * size - Size of the volume; default "10G"
  * storage - The proxmox storage pool to create the volume in
  EOT

  type = object({
    size    = optional(string, "10G")
    storage = string
  })
}

variable "ha" {
  description = <<-EOT
  The high availability configuration for each VM
  See the proxmox documentation for more information.

  * state - The desired HA state; default "ignored"
  * group - The HA group the VM will participate in; required if state is not "ignored"
  EOT

  type = object({
    state = string
    group = string
  })

  default = {
    state = "ignored"
    group = null
  }
}

variable "control_plane" {
  description = <<-EOT
  The control plane nodes in the backend of this load balancer.
  An instance of the control-plane module can be supplied directly, e.g. module.my_control_plane

  * ip_addresses - The IP addresses of the control plane nodes
  EOT

  type = list(object({
    ip_addresses = list(string)
  }))
}

variable "dns_name" {
  description = "The DNS name assigned to this node's IP address"

  type    = string
  default = null
}

variable "stats" {
  description = <<-EOT
  The HAProxy stats endpoint configuration.

  * enabled - Whether the stats endpoint is enabled
  EOT

  type = object({
    enabled = bool
  })

  default = {
    enabled = true
  }
}
