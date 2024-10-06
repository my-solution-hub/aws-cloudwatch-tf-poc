data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
