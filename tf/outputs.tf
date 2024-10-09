output msk_bootstrap_addresses {
    value = aws_msk_cluster.msk-cluster.bootstrap_brokers
}

output "redis_endpoint" {
  value = module.elasticache.replication_group_configuration_endpoint_address
}

output "redis_user" {
  value = var.redis_user
}

output "redis_password" {
  value = aws_secretsmanager_secret_version.redis_user_secret_version.secret_string
  sensitive = true
}
