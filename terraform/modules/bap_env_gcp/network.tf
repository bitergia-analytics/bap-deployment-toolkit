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

  source_ranges = var.network_fw_nginx_source_ranges
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

  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "allow-services" {
  name    = "${var.prefix}-allow-services"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["3306","5601","9200","9300","9600"]
  }

  source_ranges = ["10.0.0.0/8"]
}

resource "google_iap_tunnel_instance_iam_binding" "nginx-iap-https-policy" {
  count = var.network_iap_tunnel ? 1 : 0
  instance = split("/instances/", module.nginx.machine_id[0])[1]
  role     = "roles/iap.tunnelResourceAccessor"
  members = var.network_nginx_iap_tunnel_members

  condition {
    title      = "port 443 only"
    expression = "destination.port == 443"
  }
}
