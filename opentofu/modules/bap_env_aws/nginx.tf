module "nginx" {
  source = "../bap_aws_instance"

  prefix = var.prefix
  name   = "nginx"

  instance_count        = var.nginx_node_count
  ami_id                = var.ami_id
  instance_type         = var.nginx_instance_type
  delete_on_termination = var.delete_on_termination
  subnet_id             = aws_subnet.public.id
  availability_zone     = var.availability_zone
  iam_instance_profile   = aws_iam_instance_profile.profile_s3_full.name

  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.web.id, aws_security_group.internal.id]

  key_name         = var.key_name
  enable_public_ip = var.nginx_enable_public_ip

  root_volume_size = var.nginx_root_volume_size
  ebs_volume_count = 0

  tags = {
    "role"        = "nginx"
    "custom_tags" = var.custom_tags
  }

  ansible_groups = ["nginx"]
}
