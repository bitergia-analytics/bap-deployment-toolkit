module "mariadb" {
  source = "../bap_aws_instance"

  prefix = var.prefix
  name   = "mariadb"

  instance_count         = var.mariadb_node_count
  ami_id                 = var.ami_id
  instance_type          = var.mariadb_instance_type
  delete_on_termination  = var.delete_on_termination
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.internal.id]
  key_name               = var.key_name
  availability_zone      = var.availability_zone
  iam_instance_profile   = aws_iam_instance_profile.profile_s3_full.name

  root_volume_size = var.mariadb_root_volume_size
  ebs_volume_count = var.mariadb_ebs_volume_count != 0 ? var.mariadb_ebs_volume_count : var.mariadb_node_count
  ebs_volume_size  = var.mariadb_ebs_volume_size
  ebs_volume_type  = var.mariadb_ebs_volume_type

  tags = {
    "role"        = "mariadb"
    "custom_tags" = var.custom_tags
  }

  ansible_groups = ["mariadb"]
}
