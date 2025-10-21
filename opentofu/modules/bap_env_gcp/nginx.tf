module "nginx" {
  source = "../bap_gcp_instance"

  service_account_email        = var.service_account_email
  service_account_extra_scopes = ["storage-ro"]

  prefix                       = var.prefix
  name                         = "nginx"
  node_count                   = var.nginx_node_count
  tags                         = flatten([
                                   "nginx", "http-server", "https-server",
                                   var.custom_tags
                                 ])
  ansible_groups               = ["nginx"]

  machine_type                 = var.nginx_machine_type
  machine_image                = var.nginx_machine_image
  boot_disk_persistent         = var.persistent_disks
  boot_disk_size               = var.nginx_boot_disk_size
  zone                         = var.zone

  network                      = var.network
  subnetwork                   = var.subnetwork
  enable_external_ip           = var.nginx_enable_external_ip
  ansible_use_external_ip      = var.nginx_ansible_use_external_ip

  disk_count              = 0
}

output "nginx" {
  value = module.nginx
}
