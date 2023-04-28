# Generic

variable "project" {
  description = "Google Cloud project ID"
  type    = string
  default = "<GCP-PROJECT-ID>"
}

variable "zone" {
  type    = string
  default = "europe-southwest1-a"
}

variable "network" {
  type    = string
  default = "default"
}

variable "subnetwork" {
  type    = string
  default = "default"
}

variable "prefix" {
  type        = string
  description = "A prefix to add to the resource name(s), e.g.: '<prefix>-<name>-x'"
}

# MariaDB

variable "mariadb_node_count" {
  type    = number
  default = 1
}

variable "mariadb_machine_type" {
  type    = string
  default = "e2-standard-2" # 2vcpu, 8GB memory
}

variable "mariadb_machine_image" {
  type    = string
  default = "debian-cloud/debian-11"
}

variable "mariadb_disk_size" {
  type    = number
  default = 50
}

variable "mariadb_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "mariadb_ansible_use_external_ip" {
  type    = bool
  default = false
}

# redis

variable "redis_node_count" {
  type    = number
  default = 1
}

variable "redis_machine_type" {
  type    = string
  default = "e2-standard-2" # 2vcpu, 8GB memory
}

variable "redis_machine_image" {
  type    = string
  default = "debian-cloud/debian-11"
}

variable "redis_disk_size" {
  type    = number
  default = 50
}

variable "redis_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "redis_ansible_use_external_ip" {
  type    = bool
  default = false
}

# OpenSearch

variable "opensearch_node_count" {
  type    = number
  default = 2
}

variable "opensearch_machine_type" {
  type    = string
  default = "e2-highmem-4" # 4vcpu, 32GB memory
}

variable "opensearch_machine_image" {
  type    = string
  default = "debian-cloud/debian-11"
}

variable "opensearch_disk_size" {
  type    = number
  default = 200
}

variable "opensearch_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "opensearch_ansible_use_external_ip" {
  type    = bool
  default = false
}

# OpenSearch Dashboards

variable "opensearch_dashboards_node_count" {
  type    = number
  default = 1
}

variable "opensearch_dashboards_anonymous_node_count" {
  type    = number
  default = 0
}

variable "opensearch_dashboards_machine_type" {
  type    = string
  # default = "e2-highmem-4" # 4vcpu, 32GB memory
  default = "e2-standard-2"
}

variable "opensearch_dashboards_machine_image" {
  type    = string
  default = "debian-cloud/debian-11"
}

variable "opensearch_dashboards_disk_size" {
  type    = number
  # default = 200
  default = 50
}

variable "opensearch_dashboards_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "opensearch_dashboards_ansible_use_external_ip" {
  type    = bool
  default = false
}

# NGINX

variable "nginx_node_count" {
  type    = number
  default = 1
}

variable "nginx_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "nginx_machine_image" {
  type    = string
  default = "debian-cloud/debian-11"
}

variable "nginx_disk_size" {
  type    = number
  default = 50
}

variable "nginx_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "nginx_ansible_use_external_ip" {
  type    = bool
  default = false
}

# Mordred

variable "mordred_node_count" {
  type    = number
  default = 1
}

variable "mordred_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "mordred_machine_image" {
  type    = string
  default = "debian-cloud/debian-11"
}

variable "mordred_disk_size" {
  type    = number
  default = 50
}

variable "mordred_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "mordred_ansible_use_external_ip" {
  type    = bool
  default = false
}

# SortingHat

variable "sortinghat_node_count" {
  type    = number
  default = 1
}

variable "sortinghat_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "sortinghat_machine_image" {
  type    = string
  default = "debian-cloud/debian-11"
}

variable "sortinghat_disk_size" {
  type    = number
  default = 50
}

variable "sortinghat_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "sortinghat_ansible_use_external_ip" {
  type    = bool
  default = false
}

# SortingHat

variable "sortinghat_worker_node_count" {
  type    = number
  default = 1
}

variable "sortinghat_worker_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "sortinghat_worker_machine_image" {
  type    = string
  default = "debian-cloud/debian-11"
}

variable "sortinghat_worker_disk_size" {
  type    = number
  default = 50
}

variable "sortinghat_worker_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "sortinghat_worker_ansible_use_external_ip" {
  type    = bool
  default = false
}

# Storage

variable "backups_storage_location" {
  type    = string
  default = "EUROPE-SOUTHWEST1"
}

variable "sortinghat_storage_location" {
  type    = string
  default = "EUROPE-SOUTHWEST1"
}

variable "uniform_bucket_level_access" {
  type = bool
  default = false
}

