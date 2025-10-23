module "sortinghat" {
  source = "../bap_gcp_instance"

  service_account_email        = var.service_account_email
  service_account_extra_scopes = ["cloud-platform"]

  prefix                       = var.prefix
  name                         = "sortinghat"
  node_count                   = var.sortinghat_node_count
  tags                         = flatten([
                                   "sortinghat",
                                   var.custom_tags
                                 ])
  ansible_groups               = ["sortinghat"]

  machine_type                 = var.sortinghat_machine_type
  machine_image                = var.sortinghat_machine_image
  boot_disk_persistent         = var.persistent_disks
  boot_disk_size               = var.sortinghat_boot_disk_size
  zone                         = var.zone

  network                      = var.network
  subnetwork                   = var.subnetwork
  enable_external_ip           = false
  ansible_use_external_ip      = var.sortinghat_ansible_use_external_ip

  disk_count                   = 0
}

output "sortinghat" {
  value = module.sortinghat
}
