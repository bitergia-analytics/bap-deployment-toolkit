module "sortinghat_worker" {
  source = "../bap_gcp_instance"

  service_account_email   = var.service_account_email

  prefix                  = var.prefix
  name                    = "sortinghat-worker"
  node_count              = var.sortinghat_worker_node_count
  tags                    = flatten([
                              "sortinghat-worker",
                              var.custom_tags
                            ])
  ansible_groups          = ["sortinghat-worker"]

  machine_type            = var.sortinghat_worker_machine_type
  machine_image           = var.sortinghat_worker_machine_image
  boot_disk_persistent    = var.persistent_disks
  boot_disk_size          = var.sortinghat_worker_boot_disk_size
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.sortinghat_worker_ansible_use_external_ip

  disk_count              = 0
}

output "sortinghat_worker" {
  value = module.sortinghat_worker
}
