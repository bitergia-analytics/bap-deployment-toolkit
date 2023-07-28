module "opensearch_dashboards" {
  source = "../bap_gcp_instance"

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
  disk_size               = var.opensearch_dashboards_disk_size
  disk_type               = var.opensearch_dashboards_disk_type
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.opensearch_dashboards_ansible_use_external_ip
}

output "opensearch_dashboards" {
  value = module.opensearch_dashboards
}
