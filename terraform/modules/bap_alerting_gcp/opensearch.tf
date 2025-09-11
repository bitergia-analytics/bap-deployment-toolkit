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

# OpenSearch cluster health status metrics and alerts
resource "google_logging_metric" "opensearch_cluster_health_green_metric" {
  name        = "opensearch.cluster.health_green"
  description = "The OpenSearch cluster is healthy (green status)"
  count         = var.alerts ? 1 : 0
  filter      = "\"Cluster health status changed from\" AND \"to [GREEN]\""
}

resource "google_logging_metric" "opensearch_cluster_health_yellow_metric" {
  name        = "opensearch.cluster.health_yellow"
  description = "The OpenSearch cluster is not healthy (yellow status)"
  count         = var.alerts ? 1 : 0
  filter      = "\"Cluster health status changed from\" AND \"to [YELLOW]\""
}

resource "google_logging_metric" "opensearch_cluster_health_red_metric" {
  name        = "opensearch.cluster.health_red"
  description = "The OpenSearch cluster is not healthy (red status)"
  count         = var.alerts ? 1 : 0
  filter      = "\"Cluster health status changed from\" AND \"to [RED]\""
}

resource "google_monitoring_alert_policy" "opensearch_cluster_health_green_alert" {
  project      = var.project

  display_name = "OpenSearch - Cluster Health Green"
  count        = var.alerts ? 1 : 0

  documentation {
    content   = "The OpenSearch cluster is healthy (green status)."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  conditions {
    display_name = "OpenSearch - Cluster Health Green"

    condition_threshold {
      filter = "resource.type = \"gce_instance\" AND metric.type = \"logging.googleapis.com/user/${google_logging_metric.opensearch_cluster_health_green_metric[count.index].name}\""
      duration           = "0s"
      comparison         = "COMPARISON_GT"
      threshold_value    = 0
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_NONE"
      }

      trigger {
        count = 1
      }
    }
  }
  alert_strategy {
    notification_prompts = ["OPENED"]
  }

  notification_channels = var.notification_channels
}

resource "google_monitoring_alert_policy" "opensearch_cluster_health_yellow_alert" {
  project      = var.project

  display_name = "OpenSearch - Cluster Health Yellow"
  count        = var.alerts ? 1 : 0

  documentation {
    content   = "The OpenSearch cluster is not healthy (yellow status): Some replica shards are not assigned."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  severity = "WARNING"
  conditions {
    display_name = "OpenSearch - Cluster Health Yellow"

    condition_threshold {
      filter = "resource.type = \"gce_instance\" AND metric.type = \"logging.googleapis.com/user/${google_logging_metric.opensearch_cluster_health_yellow_metric[count.index].name}\""
      duration           = "0s"
      comparison         = "COMPARISON_GT"
      threshold_value    = 0
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_NONE"
      }

      trigger {
        count = 1
      }
    }
  }
  alert_strategy {
    notification_prompts = ["OPENED"]
  }

  notification_channels = var.notification_channels
}

resource "google_monitoring_alert_policy" "opensearch_cluster_health_red_alert" {
  project      = var.project

  display_name = "OpenSearch - Cluster Health Red"
  count        = var.alerts ? 1 : 0

  documentation {
    content   = "The OpenSearch cluster is not healthy (red status): Some primary shards are unassigned."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  severity = "CRITICAL"
  conditions {
    display_name = "OpenSearch - Cluster Health Red"

    condition_threshold {
      filter = "resource.type = \"gce_instance\" AND metric.type = \"logging.googleapis.com/user/${google_logging_metric.opensearch_cluster_health_red_metric[count.index].name}\""
      duration           = "0s"
      comparison         = "COMPARISON_GT"
      threshold_value    = 0
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_NONE"
      }

      trigger {
        count = 1
      }
    }
  }
  alert_strategy {
    notification_prompts = ["OPENED"]
  }

  notification_channels = var.notification_channels
}
