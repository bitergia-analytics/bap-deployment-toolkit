module "mordred" {
  source = "../bap_gcp_instance"

  name_prefix             = "mordred"
  node_count              = var.mordred_node_count
  tags                    = ["mordred"]
  ansible_groups          = ["mordred"]

  machine_type            = var.mordred_machine_type
  machine_image           = var.mordred_machine_image
  disk_size               = var.mordred_disk_size
  disk_type               = var.mordred_disk_type
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = false
  ansible_use_external_ip = var.mordred_ansible_use_external_ip
}

output "mordred" {
  value = module.mordred
}
