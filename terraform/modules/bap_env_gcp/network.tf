resource "google_compute_router" "router" {
  count   = 1
  name    = "${var.prefix}-bap-router"
  network = var.network
}

resource "google_compute_router_nat" "nat" {
  count  = 1
  name   = "${var.prefix}-bap-nat"
  router = google_compute_router.router[0].name

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "fw-nginx" {
  name    = "${var.prefix}-fw-nginx"
  network = var.network

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

source_ranges = ["0.0.0.0/0"]
target_tags = ["nginx", "http-server", "https-server"]
}

# resource "google_compute_firewall" "deny-ssh" {
#  name    = "deny-ssh"
#  network = var.network

#  priority = 1001

#  deny {
#    protocol = "tcp"
#    ports    = ["22"]
#  }

#source_ranges = ["0.0.0.0/0"]
#target_tags = ["control", "nginx", "http-server", "https-server"]
#}

resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.prefix}-allow-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

source_ranges = ["35.235.240.0/20", "10.0.0.0/8"]
}

resource "google_compute_firewall" "allow-services" {
  name    = "${var.prefix}-allow-services"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["3306","5601","9200","9300","9600"]
  }

source_ranges = ["35.235.240.0/20", "10.0.0.0/8"]
}
