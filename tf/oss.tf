
resource "aws_grafana_workspace" "example" {
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.grafana_assume.arn
  name = var.cluster_name
#   vpc_configuration {
#     security_group_ids = module.vpc.default_security_group_id
#     subnet_ids         = var.subnet_ids
#   }
}

resource "aws_grafana_role_association" "example" {
  role         = "ADMIN"
  user_ids     = [data.aws_identitystore_user.my_user.user_id]
  workspace_id = aws_grafana_workspace.example.id
}

resource "aws_iam_role" "grafana_assume" {
  name = "${var.cluster_name}-grafana-assume"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "assume" {
  role       = aws_iam_role.grafana_assume.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_cloudwatch_log_group" "prom_log" {
  name = "${var.cluster_name}_prom_log"
}

resource "aws_prometheus_workspace" "prom" {
  alias = var.cluster_name
  logging_configuration {
    log_group_arn = "${aws_cloudwatch_log_group.prom_log.arn}:*"
  }
}

data "aws_ssoadmin_instances" "IdP" {}

data "aws_identitystore_user" "my_user" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.IdP.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = var.grafana_user
    }
  }
}


module "iam_assumable_role_adot_collector" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  # version     = "5.37.1"
  create_role = true
  role_name   = local.role_name
  # force_detach_policies         = true
  provider_url                  = module.eks.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:observability:adot-collector"]
}

resource "aws_iam_role_policy_attachment" "adot_amp" {
  role       = module.iam_assumable_role_adot_collector.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"
}

resource "aws_iam_role_policy_attachment" "adot_xray" {
  role       = module.iam_assumable_role_adot_collector.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "adot_cloudwatch" {
  role       = module.iam_assumable_role_adot_collector.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "kubernetes_namespace" "observability" {
  metadata {
    name = "observability"
  }
}

resource "kubernetes_service_account" "adot-collector" {
  depends_on = [
    kubernetes_namespace.observability,
    # kubernetes_secret.adot-collector
  ]

  metadata {
    name      = "adot-collector"
    namespace = "observability"
    labels = {
      "app.kubernetes.io/instance" = "adot-collector"
      "app.kubernetes.io/name"     = "adot-collector"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_adot_collector.iam_role_arn
    }
  }
}

resource "kubernetes_secret" "adot-collector" {
  depends_on = [ kubernetes_service_account.adot-collector ]
  metadata {
    name      = "serviceaccount-token-secret"
    namespace = "observability"
    annotations = {
      "kubernetes.io/service-account.name"      = "adot-collector"
      "kubernetes.io/service-account.namespace" = "observability"
    }
  }
  type = "kubernetes.io/service-account-token"
}