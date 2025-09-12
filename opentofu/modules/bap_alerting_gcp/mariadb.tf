# Basic MariaDB alerts

resource "google_logging_metric" "mariadb_slow_queries_count" {
  name        = "mariadb.slow_queries.count"
  description = "Number of MariaDB slow queries"

  count         = var.alerts ? 1 : 0

  filter      = "logName : \"mysql_slow\" AND jsonPayload.message: (\"SELECT\" OR \"INSERT\" OR \"UPDATE\" OR \"CREATE\" OR \"DELETE\") AND jsonPayload.queryTime > 1"
}

resource "google_monitoring_alert_policy" "mariadb_high_slow_queries_rate" {
  project       = var.project

  display_name  = "MariaDB - High Slow Queries Rate"
  count         = var.alerts ? 1 : 0

  documentation {
    content   = "The rate of slow queries is above the threshold during the last 5m."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  conditions {
    display_name = "MariaDB - High slow queries rate"
    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type=\"logging.googleapis.com/user/mariadb.slow_queries.count\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.mariadb_slow_queries_rate_threshold
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_RATE"
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

resource "google_monitoring_alert_policy" "mariadb_absent_metrics" {
  project       = var.project

  display_name  = "MariaDB - Absent Metrics"
  count         = var.alerts ? 1 : 0

  documentation {
    content   = "No metrics were retrieved for the last 5 minutes. The service could be down."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  conditions {
    display_name = "MariaDB - No metrics retrieved"
    condition_absent {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"workload.googleapis.com/mysql.uptime\""
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
