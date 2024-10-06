resource "aws_eks_addon" "cloudwatch" {
  cluster_name                = var.cluster_name
  addon_name                  = "amazon-cloudwatch-observability"
  addon_version               = "v2.1.2-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  service_account_role_arn    = aws_iam_role.eks_cloudwatch_role.arn

}

// create a role for addon cloudwatch
// https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-addon.html
resource "aws_iam_role" "eks_cloudwatch_role" {
  name = "eks-cloudwatch-role"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
  ]

  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Principal: {
          Federated: module.eks.oidc_provider_arn
        },
        Action: [
                    "sts:AssumeRoleWithWebIdentity"
                ]
      }
    ]
  })
}