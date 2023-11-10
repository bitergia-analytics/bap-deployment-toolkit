# Generic

variable "project" {
  description = "Google Cloud project ID"
  type    = string
  default = "<GCP-PROJECT-ID>"
}

# Alerts Generic Configuration

variable "alerts" {
  type        = bool
  description = "Enable or disable the creation for alerts"
  default     = false
}

variable "notification_channels" {
  type        = list(any)
  description = "A list of channels where alerts will be sent. The format is 'projects/[PROJECT_ID_OR_NUMBER]/notificationChannels/[CHANNEL_ID]'"
  default     = []
}

# Alerts Thresholds

variable "vm_instance_high_cpu_threshold" {
  type        = string
  description = "Usage of the CPU (range 0.0 to 1.0) to fire the alert"
  default     = "0.8"
}

variable "vm_instance_high_disk_threshold" {
  type        = string
  description = "Percent usage of disk to fire the alert"
  default     = "95"
}

variable "vm_instance_high_memory_threshold" {
  type        = string
  description = "Percent of memory (% of usage) to fire the alert"
  default     = "90"
}

variable "redis_evicted_keys_threshold" {
  type        = string
  description = "Number of evicted keys to fire the alert"
  default     = "5"
}

variable "nginx_high_requests_threshold" {
  type        = string
  description = "Limit of requests rate to fire the alert"
  default     = "100"
}

variable "mariadb_slow_queries_rate_threshold" {
  type        = string
  description = "Limit of slow queries rate to fire the alert"
  default     = "5"
}
