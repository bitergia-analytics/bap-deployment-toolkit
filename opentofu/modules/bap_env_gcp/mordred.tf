module "mordred" {
  source = "../bap_gcp_instance"

  prefix                  = var.prefix
  name                    = "mordred"
  node_count              = var.mordred_node_count
  tags                    = flatten([
                              "mordred",
                              var.custom_tags
                            ])
  ansible_groups          = ["mordred"]

  machine_type            = var.mordred_machine_type
  machine_image           = var.mordred_machine_image
  boot_disk_persistent    = var.persistent_disks
  boot_disk_size          = var.mordred_boot_disk_size
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.mordred_ansible_use_external_ip

  disk_count              = var.mordred_disk_count != 0 ? var.mordred_disk_count : var.mordred_node_count
  disk_type               = var.mordred_disk_type
  disk_size               = var.mordred_disk_size
  disk_snapshot           = var.mordred_disk_snapshot
  disk_attach             = var.mordred_disk_attach
}

output "mordred" {
  value = module.mordred
}
