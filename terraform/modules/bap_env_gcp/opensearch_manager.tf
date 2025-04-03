module "opensearch_manager" {
  source = "../bap_gcp_instance"

  prefix                  = var.prefix
  name                    = "opensearch-manager"
  node_count              = var.opensearch_manager_node_count
  tags                    = flatten([
                              "opensearch-manager",
                              var.custom_tags
                            ])
  ansible_groups          = ["opensearch-manager"]

  machine_type            = var.opensearch_manager_machine_type
  machine_image           = var.opensearch_manager_machine_image
  boot_disk_persistent    = var.persistent_disks
  boot_disk_size          = var.opensearch_manager_boot_disk_size
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.opensearch_manager_ansible_use_external_ip

  disk_count              = 0
}

output "opensearch_manager" {
  value = module.opensearch_manager
}
