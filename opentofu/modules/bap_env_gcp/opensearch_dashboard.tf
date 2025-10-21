module "opensearch_dashboards" {
  source = "../bap_gcp_instance"

  service_account_email   = var.service_account_email

  prefix                  = var.prefix
  name                    = "opensearch-dashboards"
  node_count              = var.opensearch_dashboards_node_count
  tags                    = flatten([
                              "opensearch-dashboards",
                              var.custom_tags
                            ])
  ansible_groups          = ["opensearch-dashboards"]

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

output "opensearch_dashboards" {
  value = module.opensearch_dashboards
}
