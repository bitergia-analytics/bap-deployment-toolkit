output "instance_id" {
  value = aws_instance.bap.*.id
}

output "public_ip" {
  value = aws_instance.bap.*.public_ip
}

output "private_ip" {
  value = aws_instance.bap.*.private_ip
}

output "ebs_volume_id" {
  value = aws_ebs_volume.bap.*.id
}
