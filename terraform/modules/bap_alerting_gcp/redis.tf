# Basic capacity alerts for Redis

resource "google_monitoring_alert_policy" "redis_memory_fragmentation" {
  project       = var.project

  display_name  = "Redis - Memory Fragmentation Ratio"
  count         = var.alerts ? 1 : 0

  documentation {
    content   = "A fragmentation ratio less than 1.0 means that Redis is using swap memory resources. More memory is needed."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  conditions {
    display_name = "Redis - Memory fragmentation ratio"
    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"workload.googleapis.com/redis.memory.fragmentation_ratio\""
      duration        = "60s"
      comparison      = "COMPARISON_LT"
      threshold_value = 1
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = [
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

resource "google_monitoring_alert_policy" "redis_evicted_keys" {
  project       = var.project

  display_name  = "Redis - Evicted Keys"
  count         = var.alerts ? 1 : 0

  documentation {
    content   = "Under memory pressure, the system will evict keys to free up memory."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  conditions {
    display_name = "Redis - Evicted keys"
    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"workload.googleapis.com/redis.keys.evicted\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.redis_evicted_keys_threshold
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = [
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

resource "google_monitoring_alert_policy" "redis_absent_metrics" {
  project       = var.project

  display_name  = "Redis - Absent Metrics"
  count         = var.alerts ? 1 : 0

  documentation {
    content   = "No metrics were retrieved for the last 5 minutes. The service could be down."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  conditions {
    display_name = "Redis - No metrics retrieved"
    condition_absent {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"workload.googleapis.com/redis.cpu.time\""
      duration        = "300s"
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_DELTA"
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
