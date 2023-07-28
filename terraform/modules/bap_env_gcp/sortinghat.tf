module "sortinghat" {
  source = "../bap_gcp_instance"

  prefix                  = var.prefix
  name                    = "sortinghat"
  node_count              = var.sortinghat_node_count
  tags                    = flatten([
                              "sortinghat",
                              var.custom_tags
                            ])
  ansible_groups          = ["sortinghat"]

  machine_type            = var.sortinghat_machine_type
  machine_image           = var.sortinghat_machine_image
  disk_size               = var.sortinghat_disk_size
  disk_type               = var.sortinghat_disk_type
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.sortinghat_ansible_use_external_ip
}

output "sortinghat" {
  value = module.sortinghat
}
