module "all_in_one" {
  source = "../bap_aws_instance"

  prefix = var.prefix
  name   = "all-in-one"

  tags = {
    "role"        = "all-in-one"
    "custom_tags" = var.custom_tags
  }

  instance_count         = var.all_in_one_node_count
  ami_id                 = var.ami_id
  instance_type          = var.all_in_one_instance_type
  delete_on_termination  = var.delete_on_termination
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.web.id, aws_security_group.internal.id]
  key_name               = var.key_name
  availability_zone      = var.availability_zone
  root_volume_size       = var.all_in_one_root_volume_size
  enable_public_ip       = true
  iam_instance_profile   = aws_iam_instance_profile.profile_s3_full.name

  ebs_volume_count = var.all_in_one_ebs_volume_count != 0 ? var.all_in_one_ebs_volume_count : var.all_in_one_node_count
  ebs_volume_size  = var.all_in_one_ebs_volume_size

  ansible_groups        = ["all_in_one"]
  ansible_use_public_ip = true
}
