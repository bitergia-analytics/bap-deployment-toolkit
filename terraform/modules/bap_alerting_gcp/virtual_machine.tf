# Basic capacity alerts for VM Instances

resource "google_monitoring_alert_policy" "vm_instance_high_cpu" {
  project       = var.project

  display_name  = "VM Instance - High CPU Utilization"
  count         = var.alerts ? 1 : 0

  documentation {
    content   = "CPU utilization on any VM instance is above 80.0% for the last 5m."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  conditions {
    display_name = "VM Instance - High CPU utilization"
    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.vm_instance_high_cpu_threshold
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = [
          "metric.label.instance_name"
        ]
      }
      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.notification_channels
}

resource "google_monitoring_alert_policy" "vm_instance_high_disk" {
  project       = var.project

  display_name  = "VM Instance - High Disk Utilization"
  count         = var.alerts ? 1 : 0

  documentation {
    content   = "Disk utilization on any VM instance device is above 95.0% for the last 5m."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  conditions {
    display_name = "VM Instance - High Disk utilization"
    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"agent.googleapis.com/disk/percent_used\" AND metric.labels.state = \"used\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.vm_instance_high_disk_threshold
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = [
          "metric.label.device",
          "metadata.system_labels.name"
        ]
      }
      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.notification_channels
}

resource "google_monitoring_alert_policy" "vm_instance_high_memory" {
  project       = var.project

  display_name  = "VM Instance - High Memory Utilization"
  count         = var.alerts ? 1 : 0

  documentation {
    content   = "Memory utilization on any VM instance is above 90.0% for the last 5m."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  conditions {
    display_name = "VM Instance - High Memory utilization"
    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"agent.googleapis.com/memory/percent_used\" AND metric.labels.state = \"used\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.vm_instance_high_memory_threshold
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = [
          "resource.label.instance_id"
        ]
      }
      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.notification_channels
}

resource "google_monitoring_alert_policy" "vm_instance_host_error_log" {
  project       = var.project
  
  display_name  = "VM Instance - Host Error Log Detected"
  count         = var.alerts ? 1 : 0

  documentation {
    content   = "Host error detected on VM instance system_event logs."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  conditions {
    display_name = "VM Instance - Host Error Log detected"
    condition_matched_log {
      filter = "log_id(\"cloudaudit.googleapis.com/system_event\") AND operation.producer=\"compute.instances.hostError\""
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "3600s"
    }
  }

  notification_channels = var.notification_channels
}
