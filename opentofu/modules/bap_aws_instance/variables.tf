variable "prefix" {
  type        = string
  description = "A prefix to add to the resource name(s), e.g.: '<prefix>-<name>-x'"
}

variable "name" {
  type        = string
  description = "Resource name(s), e.g.: '<prefix>-<name>-x'"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags for the node"
  default     = {}
}

variable "instance_count" {
  type        = number
  description = "Number of instances to create"
  default     = 1
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the instance"
}

variable "instance_type" {
  type        = string
  description = "AWS instance type"
}

variable "subnet_id" {
  type        = string
  description = "VPC Subnet ID to launch in"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to associate with"
  default     = []
}

variable "key_name" {
  type        = string
  description = "Key name of the Key Pair to use for the instance"
  default     = null
}

variable "availability_zone" {
  type        = string
  description = "AWS availability zone to launch the instance in"
}

variable "root_volume_size" {
  type        = number
  description = "Size of the root volume in GB"
  default     = 10
}

variable "root_volume_type" {
  type        = string
  description = "Type of the root volume"
  default     = "gp3"
}

variable "delete_on_termination" {
  type        = bool
  description = "Whether to delete the root volume on termination"
  default     = false
}

variable "enable_public_ip" {
  type        = bool
  description = "Whether to associate a public IP address with an instance in a VPC"
  default     = false
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile to attach to the instance"
  default     = null
}

variable "ebs_volume_count" {
  type        = number
  description = "Number of additional EBS volumes to create"
  default     = 0
}

variable "ebs_volume_size" {
  type        = number
  description = "Size of the additional EBS volumes in GB"
  default     = 10
}

variable "ebs_volume_type" {
  type        = string
  description = "Type of the additional EBS volumes"
  default     = "gp3"
}

variable "ansible_groups" {
  type        = list(string)
  description = "List of Ansible groups the node(s)"
}

variable "ansible_use_public_ip" {
  type        = bool
  description = "Whether to use public IP for Ansible inventory"
  default     = false
}
