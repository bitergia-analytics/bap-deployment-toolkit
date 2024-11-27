# Basic OpenSearch metrics and alerts

resource "google_logging_metric" "opensearch_server_count" {
  name        = "opensearch.server.count"
  description = "Number of OpenSearch active servers"

  count         = var.alerts ? 1 : 0

  filter      = "logName =~ \"opensearch-logs$\" AND jsonPayload.level: (\"INFO\" OR \"WARN\")"
}

resource "google_monitoring_alert_policy" "opensearch_absent_metrics" {
  project       = var.project

  display_name  = "OpenSearch - Absent Metrics"
  count         = var.alerts ? 1 : 0

  documentation {
    content   = "No metrics were retrieved for the last 5 minutes. The service could be down."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  conditions {
    display_name = "OpenSearch - No metrics retrieved"
    condition_absent {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"logging.googleapis.com/user/opensearch.server.count\""
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
