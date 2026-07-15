output "mariadb_ip" {
  value = module.mariadb.private_ip
}

output "redis_ip" {
  value = module.redis.private_ip
}

output "opensearch_manager_ip" {
  value = module.opensearch_manager.private_ip
}

output "opensearch_data_ip" {
  value = module.opensearch_data.private_ip
}

output "opensearch_dashboards_ip" {
  value = module.opensearch_dashboards.private_ip
}

output "nginx_public_ip" {
  value = module.nginx.public_ip
}

output "nginx_private_ip" {
  value = module.nginx.private_ip
}

output "mordred_ip" {
  value = module.mordred.private_ip
}

output "sortinghat_ip" {
  value = module.sortinghat.private_ip
}

output "sortinghat_worker_ip" {
  value = module.sortinghat_worker.private_ip
}

output "vpc_id" {
  value = aws_vpc.bap.id
}

output "all_in_one_ip" {
  value = module.all_in_one.private_ip
}

output "opensearch_dashboards_anonymous_ip" {
  value = module.opensearch_dashboards_anonymous.private_ip
}

output "backups_bucket_name" {
  value = aws_s3_bucket.backups_assets.id
}

output "sortinghat_bucket_name" {
  value = aws_s3_bucket.sortinghat_assets.id
}
