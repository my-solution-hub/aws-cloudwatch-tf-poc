module "elasticache" {
  source = "terraform-aws-modules/elasticache/aws"

  replication_group_id = "demo-redis-cluster"

  engine_version = "7.1"
  node_type      = "cache.t4g.small"

  # Cluster mode
  cluster_mode_enabled       = true
  num_node_groups            = 2
  replicas_per_node_group    = 3
  automatic_failover_enabled = true
  multi_az_enabled           = true

  user_group_ids     = [module.elasticache_user_group.group_id]
  maintenance_window = "sun:05:00-sun:09:00"
  apply_immediately  = true

  # Security group
  vpc_id = module.vpc.vpc_id
  security_group_rules = {
    ingress_vpc = {
      # Default type is `ingress`
      # Default port is based on the default engine port
      description = "VPC traffic"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  # Subnet Group
  subnet_ids = module.vpc.private_subnets

  # Parameter Group
  create_parameter_group = true
  parameter_group_family = "redis7"
  parameters = [
    {
      name  = "latency-tracking"
      value = "yes"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "elasticache_user_group" {
  source = "terraform-aws-modules/elasticache/aws//modules/user-group"

  user_group_id = "demo-redis-cluster-ug"

  default_user = {
    user_id   = "default-user"
    passwords = ["password123456789"]
  }

  users = {
    moe = {
      access_string = "on ~* +@all"
      passwords     = ["password123456789"]
    }

    curly = {
      access_string = "on ~* +@all"

      authentication_mode = {
        type      = "password"
        passwords = ["password123456789", "password987654321"]
      }
    }
  }

}