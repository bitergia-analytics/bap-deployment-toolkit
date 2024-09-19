module "all_in_one" {
  source = "../bap_gcp_instance"

  prefix                  = var.prefix
  name                    = "all-in-one"
  node_count              = var.all_in_one_node_count
  tags                    = flatten([
                              "all-in-one",   "http-server", "https-server",
                              var.custom_tags
                            ])
  ansible_groups          = ["all_in_one"]

  machine_type            = var.all_in_one_machine_type
  machine_image           = var.all_in_one_machine_image
  boot_disk_persistent    = var.persistent_disks
  boot_disk_size          = var.all_in_one_boot_disk_size
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = true
  ansible_use_external_ip = var.all_in_one_ansible_use_external_ip

  disk_count              = var.all_in_one_disk_count != 0 ? var.all_in_one_disk_count : var.all_in_one_node_count
  disk_type               = var.all_in_one_disk_type
  disk_size               = var.all_in_one_disk_size
  disk_snapshot           = var.all_in_one_disk_snapshot
  disk_attach             = var.all_in_one_disk_attach
}

output "all_in_one" {
  value = module.all_in_one
}
