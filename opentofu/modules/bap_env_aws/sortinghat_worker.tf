module "sortinghat_worker" {
  source = "../bap_aws_instance"

  prefix = var.prefix
  name   = "sortinghat-worker"

  tags = {
    "role"        = "sortinghat-worker"
    "custom_tags" = var.custom_tags
  }

  instance_count        = var.sortinghat_worker_node_count
  ami_id                = var.ami_id
  instance_type         = var.sortinghat_worker_instance_type
  delete_on_termination = var.delete_on_termination
  key_name              = var.key_name
  availability_zone     = var.availability_zone

  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.internal.id
  ]

  root_volume_size = var.sortinghat_worker_root_volume_size
  ebs_volume_count = 0
  enable_public_ip = false

  ansible_groups        = ["sortinghat_worker"]
  ansible_use_public_ip = false
}
