module "redis" {
  source = "../bap_aws_instance"

  prefix = var.prefix
  name   = "redis"

  instance_count         = var.redis_node_count
  ami_id                 = var.ami_id
  instance_type          = var.redis_instance_type
  delete_on_termination  = var.delete_on_termination
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.internal.id]
  key_name               = var.key_name
  availability_zone      = var.availability_zone

  root_volume_size = var.redis_root_volume_size
  ebs_volume_count = var.redis_ebs_volume_count != 0 ? var.redis_ebs_volume_count : var.redis_node_count
  ebs_volume_size  = var.redis_ebs_volume_size

  tags = {
    "role"        = "redis"
    "custom_tags" = var.custom_tags
  }

  ansible_groups = ["redis"]
}
