output "machine_id" {
  value = google_compute_instance.bap.*.self_link
}

output "internal_ip" {
  value = google_compute_instance.bap.*.network_interface.0.network_ip

}

output "external_ip" {
    value       = google_compute_address.bap.*.address
    description = "The public IP address of the newly created instance"
}

output "project_id" {
  value = data.google_project.project.project_id
}
