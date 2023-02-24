module "sortinghat_worker" {
  source = "../bap_gcp_instance"

  prefix                  = var.prefix
  name                    = "sortinghat-worker"
  node_count              = var.sortinghat_worker_node_count
  tags                    = ["sortinghat-worker"]
  ansible_groups          = ["sortinghat-worker"]

  machine_type            = var.sortinghat_worker_machine_type
  machine_image           = var.sortinghat_worker_machine_image
  disk_size               = var.sortinghat_worker_disk_size
  disk_type               = var.sortinghat_worker_disk_type
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.sortinghat_worker_ansible_use_external_ip
}

output "sortinghat_worker" {
  value = module.sortinghat_worker
}
