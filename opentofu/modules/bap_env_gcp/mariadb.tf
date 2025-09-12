module "mariadb" {
  source = "../bap_gcp_instance"

  prefix                  = var.prefix
  name                    = "mariadb"
  node_count              = var.mariadb_node_count
  tags                    = flatten([
                              "identities",
                              var.custom_tags
                            ])
  ansible_groups          = ["mariadb"]

  machine_type            = var.mariadb_machine_type
  machine_image           = var.mariadb_machine_image
  boot_disk_persistent    = var.persistent_disks
  boot_disk_size          = var.mariadb_boot_disk_size
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.mariadb_ansible_use_external_ip

  disk_count              = var.mariadb_disk_count != 0 ? var.mariadb_disk_count : var.mariadb_node_count
  disk_type               = var.mariadb_disk_type
  disk_size               = var.mariadb_disk_size
  disk_snapshot           = var.mariadb_disk_snapshot
  disk_attach             = var.mariadb_disk_attach
}

output "mariadb" {
  value = module.mariadb
}
