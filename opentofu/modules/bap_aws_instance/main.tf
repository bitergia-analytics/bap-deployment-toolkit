terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

resource "aws_instance" "bap" {
  count = var.instance_count

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  key_name               = var.key_name
  availability_zone      = var.availability_zone

  associate_public_ip_address = var.enable_public_ip

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.delete_on_termination
  }

  tags = merge(
    var.tags,
    {
      Name            = "${var.prefix}-${var.name}-${count.index}"
      bap_node_type   = "${var.name}"
      bap_node_prefix = "${var.prefix}"
    }
  )

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2
  }

  iam_instance_profile = var.iam_instance_profile
}

resource "aws_ebs_volume" "bap" {
  count = var.ebs_volume_count

  availability_zone = aws_instance.bap[count.index % var.instance_count].availability_zone
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-${var.name}-disk-${count.index}"
    }
  )
}

resource "aws_volume_attachment" "bap" {
  count = var.ebs_volume_count

  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.bap[count.index].id
  instance_id = aws_instance.bap[count.index % var.instance_count].id
}
