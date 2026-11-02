# Argo CD instalado por Terraform (bootstrap do GitOps): release Helm, Secret do
# repositório GitOps (deploy key SSH) e o app-of-apps que sincroniza todo o resto.
# Tudo depois do bootstrap é gerenciado pelo próprio Argo CD a partir do Git.
#
# Opcional: role IRSA para o application-controller/server, para um Argo CD "hub"
# gerenciar outros clusters (awsAuthConfig nos Secrets de cluster). Sem a annotation o
# Argo CD cai na credencial do NÓ — funciona, mas dá a qualquer pod do node group o
# mesmo acesso do hub aos clusters alvo.

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = var.namespace
  create_namespace = true
  wait             = true

  # atomic reverte o upgrade inteiro se falhar; 900s cobre o rollout sem disparar rollback
  # num upgrade lento porém saudável.
  atomic          = true
  cleanup_on_fail = true
  timeout         = 900

  values = [yamlencode({
    global = {
      domain = var.hostname
    }
    configs = {
      params = { "server.insecure" = var.server_insecure }
      cm     = { "timeout.reconciliation" = "180s" }
    }
    controller = {
      serviceAccount = { annotations = var.irsa_role_arn == null ? {} : { "eks.amazonaws.com/role-arn" = var.irsa_role_arn } }
    }
    server = {
      serviceAccount = { annotations = var.irsa_role_arn == null ? {} : { "eks.amazonaws.com/role-arn" = var.irsa_role_arn } }
      ingress = var.hostname == null ? { enabled = false } : {
        enabled          = true
        ingressClassName = var.ingress_class_name
        hostname         = var.hostname
      }
    }
    dex = { enabled = false }
  })]
}

# Deploy key SSH do repositório GitOps. Injete via TF_VAR_gitops_repo_ssh_key (sensível;
# não aparece no plan). Prefira gravar no Secrets Manager e ler por External Secrets.
resource "kubernetes_secret" "repo" {
  metadata {
    name      = "gitops-repo"
    namespace = var.namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type          = "git"
    url           = var.gitops_repo_url
    sshPrivateKey = var.gitops_repo_ssh_key
  }

  type = "Opaque"

  depends_on = [helm_release.argocd]
}

# app-of-apps: o caminho precisa ser EXCLUSIVO deste Argo CD — dois Argo CD com selfHeal
# no mesmo caminho disputam os mesmos manifestos.
resource "kubectl_manifest" "app_of_apps" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name       = "bootstrap"
      namespace  = var.namespace
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_target_revision
        path           = var.gitops_bootstrap_path
        directory      = { recurse = true }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.namespace
      }
      syncPolicy = {
        automated   = { prune = true, selfHeal = true }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  })

  server_side_apply = true
  wait              = false

  depends_on = [helm_release.argocd, kubernetes_secret.repo]
}
