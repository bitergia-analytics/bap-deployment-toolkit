module "grimoirelab" {
  source = "../bap_gcp_instance"

  prefix                  = var.prefix
  name                    = "grimoirelab"
  node_count              = var.grimoirelab_node_count
  tags                    = flatten([
                              "grimoirelab",
                              var.custom_tags
                            ])
  ansible_groups          = ["grimoirelab"]

  machine_type            = var.grimoirelab_machine_type
  machine_image           = var.grimoirelab_machine_image
  boot_disk_persistent    = var.persistent_disks
  boot_disk_size          = var.grimoirelab_boot_disk_size
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.grimoirelab_ansible_use_external_ip

  disk_count              = var.grimoirelab_disk_count != 0 ? var.grimoirelab_disk_count : var.grimoirelab_node_count
  disk_type               = var.grimoirelab_disk_type
  disk_size               = var.grimoirelab_disk_size
  disk_snapshot           = var.grimoirelab_disk_snapshot
  disk_attach             = var.grimoirelab_disk_attach
}

output "grimoirelab" {
  value = module.grimoirelab
}
