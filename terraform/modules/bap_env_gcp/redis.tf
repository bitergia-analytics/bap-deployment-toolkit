module "redis" {
  source = "../bap_gcp_instance"

  name_prefix             = "redis"
  node_count              = var.redis_node_count
  tags                    = ["identities"]
  ansible_groups          = ["redis"]

  machine_type            = var.redis_machine_type
  machine_image           = var.redis_machine_image
  disk_size               = var.redis_disk_size
  disk_type               = var.redis_disk_type
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.redis_ansible_use_external_ip
}

output "redis" {
  value = module.redis
}
