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
  name  = "${var.name_prefix}-ip-${count.index}"
}

resource "google_compute_instance" "bap" {
  count                     = var.node_count
  project                   = data.google_project.project.project_id
  name                      = "${var.name_prefix}-${count.index}"
  machine_type              = var.machine_type
  zone                      = var.zone
  allow_stopping_for_update = true

  tags = flatten([
    "terraform",
    var.tags
  ])

  labels = merge({
    bap_node_type = "${var.name_prefix}"
  })

  boot_disk {
    initialize_params {
      image = var.machine_image
      size  = var.disk_size
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

  service_account {
    scopes = var.service_account_scopes
  }
}
