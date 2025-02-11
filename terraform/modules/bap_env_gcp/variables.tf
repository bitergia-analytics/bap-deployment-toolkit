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

variable "custom_tags" {
  type        = list(any)
  description = "A list of extra tags for each compute engine"
  default     = []
}

variable "machine_image" {
  type    = string
  default = "debian-cloud/debian-12"
}

variable "persistent_disks" {
  type        = bool
  description = "Whether the disks will be auto-deleted when the instance is deleted"
  default     = false
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
  default = "debian-cloud/debian-12"
}

variable "mariadb_boot_disk_size" {
  type    = number
  default = 10
}

variable "mariadb_disk_count" {
  type    = number
  default = 0
}

variable "mariadb_disk_size" {
  type    = number
  default = 50
}

variable "mariadb_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "mariadb_disk_attach" {
  type        = string
  description = "Instance ID to attach MariaDB disk"
  default     = ""
}

variable "mariadb_disk_snapshot" {
  type = string
  description = "The source snapshot used to create this disk"
  default = null
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
  default = "debian-cloud/debian-12"
}

variable "redis_boot_disk_size" {
  type    = number
  default = 10
}

variable "redis_disk_count" {
  type    = number
  default = 0
}

variable "redis_disk_size" {
  type    = number
  default = 50
}

variable "redis_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "redis_disk_attach" {
  type        = string
  description = "Instance ID to attach Redis disk"
  default     = ""
}

variable "redis_disk_snapshot" {
  type = string
  description = "The source snapshot used to create this disk"
  default = null
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
  default = "debian-cloud/debian-12"
}

variable "opensearch_boot_disk_size" {
  type    = number
  default = 10
}

variable "opensearch_disk_count" {
  type    = number
  default = 0
}

variable "opensearch_disk_size" {
  type    = number
  default = 200
}

variable "opensearch_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "opensearch_disk_attach" {
  type        = string
  description = "Instance ID to attach OpenSearch disk"
  default     = ""
}

variable "opensearch_disk_snapshot" {
  type = string
  description = "The source snapshot used to create this disk"
  default = null
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
  default = "debian-cloud/debian-12"
}

variable "opensearch_dashboards_boot_disk_size" {
  type    = number
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
  default = "debian-cloud/debian-12"
}

variable "nginx_boot_disk_size" {
  type    = number
  default = 50
}

variable "nginx_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "nginx_enable_external_ip" {
  type    = bool
  default = true
}

variable "nginx_ansible_use_external_ip" {
  type    = bool
  default = false
}

# grimoirelab

variable "grimoirelab_node_count" {
  type    = number
  default = 1
}

variable "grimoirelab_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "grimoirelab_machine_image" {
  type    = string
  default = "debian-cloud/debian-12"
}

variable "grimoirelab_boot_disk_size" {
  type    = number
  default = 10
}

variable "grimoirelab_disk_count" {
  type    = number
  default = 0
}

variable "grimoirelab_disk_size" {
  type    = number
  default = 50
}

variable "grimoirelab_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "grimoirelab_disk_attach" {
  type        = string
  description = "Instance ID to attach MariaDB disk"
  default     = ""
}

variable "grimoirelab_disk_snapshot" {
  type = string
  description = "The source snapshot used to create this disk"
  default = null
}

variable "grimoirelab_ansible_use_external_ip" {
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
  default = "debian-cloud/debian-12"
}

variable "sortinghat_boot_disk_size" {
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

# SortingHat Worker

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
  default = "debian-cloud/debian-12"
}

variable "sortinghat_worker_boot_disk_size" {
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

# Network

variable "network_fw_nginx_source_ranges" {
  type = list(any)
  description = "A list of source ranges"
  default     = ["0.0.0.0/0"]
}

variable "network_nginx_iap_tunnel_members" {
  type = list(any)
  description = "A list of IAP members, e.g.: ['user:example@example.com', 'group:dev@example.com']"
  default     = []
}

variable "network_iap_tunnel" {
  type        = bool
  description = "Activate IAP tunnel"
  default     = false
}

# All services in one VM

variable "all_in_one_node_count" {
  type    = number
  default = 0
}

variable "all_in_one_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "all_in_one_machine_image" {
  type    = string
  default = "debian-cloud/debian-12"
}

variable "all_in_one_boot_disk_size" {
  type    = number
  default = 10
}

variable "all_in_one_disk_count" {
  type    = number
  default = 0
}

variable "all_in_one_disk_size" {
  type    = number
  default = 300
}

variable "all_in_one_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "all_in_one_disk_attach" {
  type        = string
  description = "Instance ID to attach MariaDB disk"
  default     = ""
}

variable "all_in_one_disk_snapshot" {
  type = string
  description = "The source snapshot used to create this disk"
  default = null
}

variable "all_in_one_ansible_use_external_ip" {
  type    = bool
  default = false
}
