# Basic capacity alerts for NGINX

resource "google_monitoring_alert_policy" "nginx_high_requests" {
  project       = var.project

  display_name  = "NGINX - High Requests Rate"
  count         = var.alerts ? 1 : 0

  documentation {
    content   = "The traffic is above the threshold during the last 5 m. The request rate needs to be monitored beforehand to understand what qualifies as a normal request rate so a threshold can be established."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  conditions {
    display_name = "NGINX - High requests rate"
    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"workload.googleapis.com/nginx.requests\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.nginx_high_requests_threshold
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

resource "google_monitoring_alert_policy" "nginx_high_connections_dropped" {
  project       = var.project

  display_name  = "NGINX - High Connections Dropped"
  count         = var.alerts ? 1 : 0

  documentation {
    content   = "The number of connections dropped should be near 0. When this value is rising, it means you may have a resource saturation problem."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  conditions {
    display_name = "NGINX - Connections dropped > 0"
    condition_monitoring_query_language {
      query           = "{ \n    t_0: fetch gce_instance::workload.googleapis.com/nginx.connections_accepted\n    ;\n    t_1: fetch gce_instance::workload.googleapis.com/nginx.connections_handled\n}\n| outer_join 0\n| value val(0) - val(1)\n| align rate(5m)\n| condition val() > 0\n"
      duration        = "60s"
      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.notification_channels
}

resource "google_monitoring_alert_policy" "nginx_absent_metrics" {
  project       = var.project

  display_name  = "NGINX - Absent Metrics"
  count         = var.alerts ? 1 : 0

  documentation {
    content   = "No metrics were retrieved for the last 5 minutes. The service could be down."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  conditions {
    display_name = "NGINX - No metrics retrieved"
    condition_absent {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"workload.googleapis.com/nginx.requests\""
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

# Alert for Certbot

resource "google_logging_metric" "log_error_metric" {
  project     = var.project

  name        = "error_logs_count"
  description = "Count the number of logs with severity ERROR"

  # Filter to find logs with severity ERROR.
  filter      = "logName =~ \"certbot_renew$\" AND jsonPayload.level: \"ERROR\""

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    display_name = "NGINX - Certbot ERROR Logs Count"
    labels {
      key         = "service"
      value_type  = "STRING"
      description = "Name of the service that emitted the log."
    }
  }

  # Configuration to extract the 'service' label value from the log
  label_extractors = {
    "service" = "EXTRACT(jsonPayload.service)"
  }
}

resource "google_monitoring_alert_policy" "log_error_alert" {
  project      = var.project

  display_name = "NGINX - Certbot fails to renew certificates"
  count        = var.alerts ? 1 : 0

  documentation {
    content   = "ERROR found in the Certbot renew script."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  severity = "ERROR"
  conditions {
    display_name = "NGINX - Certbot ERROR found in logs"

    condition_threshold {
      filter = "resource.type = \"gce_instance\" AND metric.type = \"logging.googleapis.com/user/${google_logging_metric.log_error_metric.name}\""
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

  notification_channels = var.notification_channels
}
