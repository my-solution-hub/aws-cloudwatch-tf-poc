# resource "aws_eks_addon" "cloudwatch" {
#   cluster_name                = var.cluster_name
#   addon_name                  = "amazon-cloudwatch-observability"
#   addon_version               = "v2.1.2-eksbuild.1"
#   resolve_conflicts_on_create = "OVERWRITE"
#   service_account_role_arn    = aws_iam_role.eks_cloudwatch_role.arn
# }

# create k8s namespace
resource "kubernetes_namespace" "adot_namespace" {
  metadata {
    name = var.adot_namespace
  }
  depends_on = [ module.eks ]
}

resource "aws_eks_addon" "adot" {
  depends_on = [
    helm_release.cert-manager,
    kubernetes_cluster_role_binding.eks_addon_manager_otel,
    kubernetes_role_binding.eks_addon_manager
  ]

  cluster_name  = var.cluster_name
  addon_name    = "adot"
  addon_version = "v0.109.0-eksbuild.2"
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

// add CreateLogStream permission to the eks-cloudwatch-role
resource "aws_iam_role_policy" "eks_cloudwatch_log_stream" {
  name = "eks-cloudwatch-log-stream"
  role = aws_iam_role.eks_cloudwatch_role.id

  policy = data.aws_iam_policy_document.cloudwatch_log_stream.json
}

data "aws_iam_policy_document" "cloudwatch_log_stream" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogGroup",
    ]
    resources = ["*"]
  }
}


resource "kubernetes_cluster_role" "eks_addon_manager_otel" {
  metadata {
    name = "eks:addon-manager-otel"
  }

  rule {
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups     = ["apiextensions.k8s.io"]
    resources      = ["customresourcedefinitions"]
    resource_names = ["opentelemetrycollectors.opentelemetry.io", "instrumentations.opentelemetry.io"]
  }

  rule {
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups     = [""]
    resources      = ["namespaces"]
    resource_names = [var.adot_namespace]
  }

  rule {
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups     = ["rbac.authorization.k8s.io"]
    resources      = ["clusterroles"]
    resource_names = ["opentelemetry-operator-manager-role", "opentelemetry-operator-metrics-reader", "opentelemetry-operator-proxy-role"]
  }

  rule {
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups     = ["rbac.authorization.k8s.io"]
    resources      = ["clusterrolebindings"]
    resource_names = ["opentelemetry-operator-manager-rolebinding", "opentelemetry-operator-proxy-rolebinding"]
  }

  rule {
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups     = ["admissionregistration.k8s.io"]
    resources      = ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
    resource_names = ["opentelemetry-operator-mutating-webhook-configuration", "opentelemetry-operator-validating-webhook-configuration"]
  }

  rule {
    verbs             = ["get"]
    non_resource_urls = ["/metrics"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = [""]
    resources  = ["serviceaccounts"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = [""]
    resources  = ["services"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["apps"]
    resources  = ["daemonsets"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["apps"]
    resources  = ["deployments"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["apps"]
    resources  = ["replicasets"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["apps"]
    resources  = ["statefulsets"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
  }

  rule {
    verbs      = ["create", "get", "list", "update"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["opentelemetry.io"]
    resources  = ["opentelemetrycollectors"]
  }

  rule {
    verbs      = ["get", "patch", "update"]
    api_groups = ["opentelemetry.io"]
    resources  = ["opentelemetrycollectors/finalizers"]
  }

  rule {
    verbs      = ["get", "patch", "update"]
    api_groups = ["opentelemetry.io"]
    resources  = ["opentelemetrycollectors/status"]
  }

  rule {
    verbs      = ["get", "list", "patch", "update", "watch"]
    api_groups = ["opentelemetry.io"]
    resources  = ["instrumentations"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["authentication.k8s.io"]
    resources  = ["tokenreviews"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["authorization.k8s.io"]
    resources  = ["subjectaccessreviews"]
  }

  depends_on = [ kubernetes_namespace.adot_namespace ]
}

resource "kubernetes_cluster_role_binding" "eks_addon_manager_otel" {
  metadata {
    name = "eks:addon-manager-otel"
  }

  subject {
    kind = "User"
    name = "eks:addon-manager"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "eks:addon-manager-otel"
  }
}

resource "kubernetes_role" "eks_addon_manager" {
  metadata {
    name      = "eks:addon-manager"
    namespace = var.adot_namespace
  }

  rule {
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups     = [""]
    resources      = ["serviceaccounts"]
    resource_names = ["opentelemetry-operator-controller-manager"]
  }

  rule {
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups     = ["rbac.authorization.k8s.io"]
    resources      = ["roles"]
    resource_names = ["opentelemetry-operator-leader-election-role"]
  }

  rule {
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups     = ["rbac.authorization.k8s.io"]
    resources      = ["rolebindings"]
    resource_names = ["opentelemetry-operator-leader-election-rolebinding"]
  }

  rule {
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups     = [""]
    resources      = ["services"]
    resource_names = ["opentelemetry-operator-controller-manager-metrics-service", "opentelemetry-operator-webhook-service"]
  }

  rule {
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups     = ["apps"]
    resources      = ["deployments"]
    resource_names = ["opentelemetry-operator-controller-manager"]
  }

  rule {
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups     = ["cert-manager.io"]
    resources      = ["certificates", "issuers"]
    resource_names = ["opentelemetry-operator-serving-cert", "opentelemetry-operator-selfsigned-issuer"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs      = ["get", "update", "patch"]
    api_groups = [""]
    resources  = ["configmaps/status"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["list"]
    api_groups = [""]
    resources  = ["pods"]
  }

  depends_on = [ kubernetes_namespace.adot_namespace ]
}

resource "kubernetes_role_binding" "eks_addon_manager" {
  metadata {
    name      = "eks:addon-manager"
    namespace = var.adot_namespace
  }

  subject {
    kind = "User"
    name = "eks:addon-manager"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "eks:addon-manager"
  }
  depends_on = [ kubernetes_namespace.adot_namespace ]
}


resource "kubernetes_cluster_role" "otel-prometheus-role" {
  metadata {
    name = "otel-prometheus-role"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "pods", "services", "endpoints", "nodes/proxy"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }

}

resource "kubernetes_cluster_role_binding" "otel-prometheus-role-binding" {
  metadata {
    name = "otel-prometheus-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "otel-prometheus-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "adot-collector"
    namespace = "observability"
  }
}
