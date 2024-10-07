output msk_bootstrap_addresses {
    value = aws_msk_cluster.msk-cluster.bootstrap_brokers
}

output "redis_host" {
  value = module.elasticache.cluster_configuration_endpoint
}
