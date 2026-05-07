variable "prefix" {
  type        = string
  description = "A prefix to add to the resource name(s), e.g.: '<prefix>-<name>-x'"
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "eu-west-1"
}

variable "availability_zone" {
  type        = string
  description = "AWS availability zone"
  default     = "eu-west-1a"
}

variable "ssh_source_ranges" {
  type        = list(string)
  description = "CIDR blocks to allow SSH access from"
  default     = ["0.0.0.0/0"]
}

variable "web_source_ranges" {
  type        = list(string)
  description = "CIDR blocks to allow HTTP/HTTPS access from"
  default     = ["0.0.0.0/0"]
}

variable "key_name" {
  type        = string
  description = "Key name of the Key Pair to use for the instances"
  default     = null
}

variable "ami_id" {
  type        = string
  description = "AMI ID for all instances"
  default     = "ami-0a3ad108ca9a42423"
}

variable "delete_on_termination" {
  type    = bool
  default = true
}

# --- MariaDB ---

variable "mariadb_node_count" {
  type    = number
  default = 1
}

variable "mariadb_instance_type" {
  type    = string
  default = "t3.small"
}

variable "mariadb_root_volume_size" {
  type    = number
  default = 10
}

variable "mariadb_ebs_volume_count" {
  type    = number
  default = 0
}

variable "mariadb_ebs_volume_size" {
  type    = number
  default = 50
}

variable "mariadb_ebs_volume_type" {
  type    = string
  default = "gp3"
}

# --- Redis ---

variable "redis_node_count" {
  type    = number
  default = 1
}

variable "redis_instance_type" {
  type    = string
  default = "t3.small"
}

variable "redis_root_volume_size" {
  type    = number
  default = 10
}

variable "redis_ebs_volume_count" {
  type    = number
  default = 0
}

variable "redis_ebs_volume_size" {
  type    = number
  default = 50
}

# --- OpenSearch Manager ---

variable "opensearch_manager_node_count" {
  type    = number
  default = 1
}

variable "opensearch_manager_instance_type" {
  type    = string
  default = "t3.small"
}

variable "opensearch_manager_root_volume_size" {
  type    = number
  default = 10
}

variable "opensearch_manager_ebs_volume_count" {
  type    = number
  default = 0
}

variable "opensearch_manager_ebs_volume_size" {
  type    = number
  default = 200
}

# --- OpenSearch Data ---

variable "opensearch_data_node_count" {
  type    = number
  default = 2
}

variable "opensearch_data_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "opensearch_data_root_volume_size" {
  type    = number
  default = 10
}

variable "opensearch_data_ebs_volume_count" {
  type    = number
  default = 0
}

variable "opensearch_data_ebs_volume_size" {
  type    = number
  default = 200
}

# --- OpenSearch Dashboards ---

variable "opensearch_dashboards_node_count" {
  type    = number
  default = 1
}

variable "opensearch_dashboards_instance_type" {
  type    = string
  default = "t3.small"
}

variable "opensearch_dashboards_root_volume_size" {
  type    = number
  default = 50
}

# --- Nginx ---

variable "nginx_node_count" {
  type    = number
  default = 1
}

variable "nginx_instance_type" {
  type    = string
  default = "t3.small"
}

variable "nginx_root_volume_size" {
  type    = number
  default = 50
}

variable "nginx_enable_public_ip" {
  type    = bool
  default = true
}

# --- Mordred ---

variable "mordred_node_count" {
  type    = number
  default = 1
}

variable "mordred_instance_type" {
  type    = string
  default = "t3.small"
}

variable "mordred_root_volume_size" {
  type    = number
  default = 10
}

variable "mordred_ebs_volume_count" {
  type    = number
  default = 0
}

variable "mordred_ebs_volume_size" {
  type    = number
  default = 50
}

# --- SortingHat ---

variable "sortinghat_node_count" {
  type    = number
  default = 1
}

variable "sortinghat_instance_type" {
  type    = string
  default = "t3.small"
}

variable "sortinghat_root_volume_size" {
  type    = number
  default = 50
}

# --- SortingHat Worker ---

variable "sortinghat_worker_node_count" {
  type    = number
  default = 1
}

variable "sortinghat_worker_instance_type" {
  type    = string
  default = "t3.small"
}

variable "sortinghat_worker_root_volume_size" {
  type    = number
  default = 50
}

# --- Custom Tags ---

variable "custom_tags" {
  type        = string
  description = "A string of custom tags to add to all resources"
  default     = ""
}

# --- All In One ---

variable "all_in_one_node_count" {
  type    = number
  default = 0
}

variable "all_in_one_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "all_in_one_root_volume_size" {
  type    = number
  default = 50
}

variable "all_in_one_ebs_volume_count" {
  type    = number
  default = 0
}

variable "all_in_one_ebs_volume_size" {
  type    = number
  default = 50
}

# --- OpenSearch Dashboards Anonymous ---

variable "opensearch_dashboards_anonymous_node_count" {
  type    = number
  default = 0
}

variable "opensearch_dashboards_anonymous_instance_type" {
  type    = string
  default = "t3.small"
}

variable "opensearch_dashboards_anonymous_root_volume_size" {
  type    = number
  default = 50
}
