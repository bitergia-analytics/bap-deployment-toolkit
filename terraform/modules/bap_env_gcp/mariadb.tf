module "mariadb" {
  source = "../bap_gcp_instance"

  prefix                  = var.prefix
  name                    = "mariadb"
  node_count              = var.mariadb_node_count
  tags                    = ["identities"]
  ansible_groups          = ["mariadb"]

  machine_type            = var.mariadb_machine_type
  machine_image           = var.mariadb_machine_image
  disk_size               = var.mariadb_disk_size
  disk_type               = var.mariadb_disk_type
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.mariadb_ansible_use_external_ip
}

output "mariadb" {
  value = module.mariadb
}
