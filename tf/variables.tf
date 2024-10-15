variable "region" {
  # set default to singapore region
  default = "ap-southeast-1"
}

variable "cluster_name" {
  default = "cloudwatch-poc"
}

variable "username" {
  default = "administrator"
}

variable "redis_user" {
  default = "moe"
}

variable "adot_namespace" {
  default = "opentelemetry-operator-system"
}

variable "grafana_user" {
  default = "admin"
}