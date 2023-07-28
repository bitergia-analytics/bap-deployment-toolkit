module "nginx" {
  source = "../bap_gcp_instance"

  prefix                  = var.prefix
  name                    = "nginx"
  node_count              = var.nginx_node_count
  tags                    = flatten([
                              "nginx", "http-server", "https-server",
                              var.custom_tags
                            ])
  ansible_groups          = ["nginx"]

  machine_type            = var.nginx_machine_type
  machine_image           = var.nginx_machine_image
  disk_size               = var.nginx_disk_size
  disk_type               = var.nginx_disk_type
  zone                    = var.zone

  network                 = var.network
  subnetwork              = var.subnetwork
  enable_external_ip      = true
  ansible_use_external_ip = var.nginx_ansible_use_external_ip
}

output "nginx" {
  value = module.nginx
}
