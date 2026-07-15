module "opensearch_dashboards_anonymous" {
  source = "../bap_aws_instance"

  prefix = var.prefix
  name   = "opensearch-dashboards-anonymous"

  tags = {
    "role"        = "opensearch-dashboards-anonymous"
    "custom_tags" = var.custom_tags
  }

  instance_count         = var.opensearch_dashboards_anonymous_node_count
  ami_id                 = var.ami_id
  instance_type          = var.opensearch_dashboards_anonymous_instance_type
  delete_on_termination  = var.delete_on_termination
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.internal.id]
  key_name               = var.key_name
  availability_zone      = var.availability_zone

  root_volume_size = var.opensearch_dashboards_anonymous_root_volume_size
  ebs_volume_count = 0
  enable_public_ip = false

  ansible_groups        = ["opensearch_dashboards_anonymous"]
  ansible_use_public_ip = false
}
