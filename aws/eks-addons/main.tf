# Addons de plataforma de um cluster EKS: Cluster Autoscaler, AWS Load Balancer Controller
# (IngressClass interna padrão), Metrics Server e External Secrets Operator. As roles IRSA
# de cada controlador são criadas fora (ex.: módulo eks-cluster + políticas próprias).
#
# O LBC é instalado PRIMEIRO: seu webhook de mutação intercepta Services/Pods; se outro
# chart sobe enquanto o webhook não responde, o apply falha com "no endpoints available".
# ── Cluster Autoscaler ────────────────────────────────────────────────────────
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = var.cluster_autoscaler_chart_version # alinhe o app ao minor do cluster

  atomic          = var.helm_release_atomic
  cleanup_on_fail = var.helm_release_atomic

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.cluster_autoscaler_role_arn
  }

  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = "true"
  }

  set {
    name  = "extraArgs.skip-nodes-with-system-pods"
    value = "false"
  }

  depends_on = [helm_release.aws_load_balancer_controller]
}

# ── AWS Load Balancer Controller ──────────────────────────────────────────────
#
# É este release que cria a IngressClass `alb-internal` e a marca como padrão do
# cluster — por `set` do chart, e não por manifesto, porque manifesto exigiria conexão
# com o cluster em tempo de plan.
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.aws_lbc_chart_version

  atomic          = var.helm_release_atomic
  cleanup_on_fail = var.helm_release_atomic

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.aws_lbc_role_arn
  }

  # Tráfego direto para o IP do pod, sem duplo NAT pelo nó.
  set {
    name  = "defaultTargetType"
    value = "ip"
  }

  set {
    name  = "ingressClass"
    value = "alb-internal"
  }

  set {
    name  = "createIngressClassResource"
    value = "true"
  }

  # Padrão do cluster: Ingress sem className nasce INTERNO (default seguro). Exposição
  # pública exige IngressClass explícita.
  set {
    name  = "ingressClassConfig.default"
    value = "true"
  }

  set {
    name  = "ingressClassParams.create"
    value = "true"
  }

  set {
    name  = "ingressClassParams.spec.scheme"
    value = "internal"
  }
}

# ── Metrics Server ────────────────────────────────────────────────────────────
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.metrics_server_chart_version

  atomic          = var.helm_release_atomic
  cleanup_on_fail = var.helm_release_atomic

  set {
    name  = "args[0]"
    value = "--kubelet-preferred-address-types=InternalIP"
  }

  depends_on = [helm_release.aws_load_balancer_controller]
}
