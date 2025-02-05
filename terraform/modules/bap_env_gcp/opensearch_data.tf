module "opensearch_data" {
  source = "../bap_gcp_instance"

  prefix                  = var.prefix
  name                    = "opensearch-data"
  node_count              = var.opensearch_data_node_count
  tags                    = flatten([
                              "opensearch-data",
                              var.custom_tags
                            ])
  ansible_groups          = ["opensearch-data"]

  machine_type            = var.opensearch_data_machine_type
  machine_image           = var.opensearch_data_machine_image
  boot_disk_persistent    = var.persistent_disks
  boot_disk_size          = var.opensearch_data_boot_disk_size
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.opensearch_data_ansible_use_external_ip

  disk_count              = var.opensearch_data_disk_count != 0 ? var.opensearch_data_disk_count : var.opensearch_data_node_count
  disk_type               = var.opensearch_data_disk_type
  disk_size               = var.opensearch_data_disk_size
  disk_snapshot           = var.opensearch_data_disk_snapshot
  disk_attach             = var.opensearch_data_disk_attach
}

output "opensearch_data" {
  value = module.opensearch_data
}
