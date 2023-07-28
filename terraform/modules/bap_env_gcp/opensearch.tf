module "opensearch" {
  source = "../bap_gcp_instance"

  prefix                  = var.prefix
  name                    = "opensearch"
  node_count              = var.opensearch_node_count
  tags                    = flatten([
                              "opensearch",
                              var.custom_tags
                            ])
  ansible_groups          = ["opensearch"]

  machine_type            = var.opensearch_machine_type
  machine_image           = var.opensearch_machine_image
  disk_size               = var.opensearch_disk_size
  disk_type               = var.opensearch_disk_type
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.opensearch_ansible_use_external_ip
}

output "opensearch" {
  value = module.opensearch
}
