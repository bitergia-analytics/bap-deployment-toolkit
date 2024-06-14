terraform {
  required_version = ">= 1.0"

  required_providers {
      google = {
        source = "hashicorp/google"
      }
      ansible = {
        source  = "nbering/ansible"
        version = "~> 1.0.4"
      }
    }
}

data "google_project" "project" {
}

resource "google_compute_address" "bap" {
  count = var.enable_external_ip ? var.node_count : 0
  name  = "${var.prefix}-${var.name}-ip-${count.index}"
}

resource "google_compute_instance" "bap" {
  count                     = var.node_count
  project                   = data.google_project.project.project_id
  name                      = "${var.prefix}-${var.name}-${count.index}"
  machine_type              = var.machine_type
  zone                      = var.zone
  allow_stopping_for_update = true

  tags = flatten([
    "terraform",
    var.tags
  ])

  labels = merge({
    bap_node_type = "${var.name}"
  })

  boot_disk {
    auto_delete = !var.boot_disk_persistent
    initialize_params {
      image = var.machine_image
      size  = var.boot_disk_size
      type  = var.disk_type
    }
  }

  metadata = var.metadata

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    dynamic "access_config" {
      for_each = var.enable_external_ip ? [google_compute_address.bap[count.index].address] : []
      content {
        nat_ip = access_config.value
      }
    }
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }

  service_account {
    scopes = flatten([
      "logging-write",
      "monitoring-write",
      var.service_account_extra_scopes
    ])
  }
}

resource "google_compute_disk" "bap" {
  count    = var.disk_count
  name     = "${var.prefix}-${var.name}-disk-${count.index}"
  type     = var.disk_type
  size     = var.disk_size
  image    = var.disk_snapshot == null ? var.machine_image : ""
  snapshot = var.disk_snapshot
  zone     = var.zone

}

resource "google_compute_attached_disk" "bap" {
  count    = var.disk_count
  disk     = google_compute_disk.bap[count.index].id
  instance = var.disk_attach != "" ? var.disk_attach : "${var.prefix}-${var.name}-${count.index}"
}
