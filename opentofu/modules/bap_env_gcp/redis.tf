module "redis" {
  source = "../bap_gcp_instance"

  service_account_email   = var.service_account_email

  prefix                  = var.prefix
  name                    = "redis"
  node_count              = var.redis_node_count
  tags                    = flatten([
                              "identities",
                              var.custom_tags
                            ])
  ansible_groups          = ["redis"]

  machine_type            = var.redis_machine_type
  machine_image           = var.redis_machine_image
  boot_disk_persistent    = var.persistent_disks
  boot_disk_size          = var.redis_boot_disk_size
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.redis_ansible_use_external_ip

  disk_count              = var.redis_disk_count != 0 ? var.redis_disk_count : var.redis_node_count
  disk_type               = var.redis_disk_type
  disk_size               = var.redis_disk_size
  disk_snapshot           = var.redis_disk_snapshot
  disk_attach             = var.redis_disk_attach
}

output "redis" {
  value = module.redis
}
