module "opensearch_dashboards_anonymous" {
  source = "../bap_gcp_instance"

  prefix                  = var.prefix
  name                    = "opensearch-dashboards-anonymous"
  node_count              = var.opensearch_dashboards_anonymous_node_count
  tags                    = flatten([
                              "opensearch-dashboards-anonymous",
                              var.custom_tags
                            ])
  ansible_groups          = ["opensearch-dashboards-anonymous"]

  machine_type            = var.opensearch_dashboards_machine_type
  machine_image           = var.opensearch_dashboards_machine_image
  boot_disk_persistent    = var.persistent_disks
  boot_disk_size          = var.opensearch_dashboards_boot_disk_size
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.opensearch_dashboards_ansible_use_external_ip

  disk_count              = 0
}

output "opensearch_dashboards_anonymous" {
  value = module.opensearch_dashboards_anonymous
}
