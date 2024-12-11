locals {
  cert_mgr_ns = "cert-manager"
  role_name = "${var.cluster_name}-adot-collector"
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = local.cert_mgr_ns
  }
  depends_on = [ module.eks ]
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  namespace        = local.cert_mgr_ns
  create_namespace = false
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  version          = "v1.16.1"

  set {
    name  = "startupapicheck.enabled"
    value = "false"
  }

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [
    kubernetes_namespace.cert-manager
  ]
}
