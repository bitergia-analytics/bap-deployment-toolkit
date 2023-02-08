variable "name_prefix" {
  type        = string
  description = "A prefix to add to the node name(s), e.g.: '<prefix>-x'"
}

variable "tags" {
  type        = list(any)
  description = "A list of tags for the node"
  default     = []
}

variable "metadata" {
  description = "Map of metadata values for the instances"
  default     = {}
}

variable "node_count" {
  type        = number
  description = "Number of nodes of a resource"
  default     = 1
}

variable "zone" {
  type        = string
  description = "GPC zone where the image will be created"
}

variable "machine_type" {
  type        = string
  description = "Google compute instance type for each node"
}

variable "machine_image" {
  type        = string
  description = "OS distribution image"
  default     = "debian-cloud/debian-11"
}

variable "disk_size" {
  type        = number
  description = "Disk size for each node"
}

variable "disk_type" {
  type        = string
  description = "Disk type for each node"
}

variable "network" {
  type        = string
  description = "VPC network name"
  default     = "default"
}

variable "subnetwork" {
  type        = string
  description = "VPC subnetwork within the network"
  default     = "default"
}

variable "enable_external_ip" {
  type        = bool
  description = "Whether to enable the external IP address in the node"
  default     = false
}

variable "service_account_scopes" {
  type        = list(string)
  description = "List of Service Account scopes to apply to the instances"
  default = [
    "logging-write",
    "monitoring-write"
  ]
}

variable "ansible_use_external_ip" {
  type        = bool
  description = "Whether feed the external or internal IP address to Ansible"
  default     = false
}

variable "ansible_groups" {
  type        = list(string)
  description = "List of Ansible groups the node(s)"
}
