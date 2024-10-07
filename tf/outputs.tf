output msk_bootstrap_addresses {
    value = aws_msk_cluster.msk-cluster.bootstrap_brokers
}