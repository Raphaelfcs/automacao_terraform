# Janela de funcionamento dos nos de um cluster EKS — decisão de arquitetura, D10.
#
# Zera os NOS fora do horario comercial. O que NAO para de cobrar: control plane (US$ 0,10/h
# por cluster), NAT gateway, EBS dos PVCs, NLB/ALB, Elastic IP. O no e o custo variavel, e e
# o unico que esta decisao ataca.
#
# ── Por que `max_size = 0` na descida, e nao so desired/min ────────────────
#
#  Com o teto acima de zero, qualquer coisa que veja pod Pending sobe no de novo: o
# cluster-autoscaler, se estiver instalado, ou o proprio EKS ao reparar um no "unhealthy".
# A acao agendada e o autoscaler brigam a cada ciclo, e o sintoma e no que nasce e morre a
# noite inteira — com cobranca de hora cheia em cada nascimento.
#
# ── Por que o nome do ASG vem de data source ──────────────────────────────
#
# `terraform/modules/eks` nao expoe o ASG do node group, e esta arvore nao altera
# `terraform/`. O `depends_on` no bloco `module` adia a LEITURA para o apply, depois de o
# node group existir — sem ele, o plan de um cluster novo falha com "couldn't find resource".
locals {
  asg_por_pool = {
    for k, ng in data.aws_eks_node_group.pool :
    k => try(one(ng.resources[0].autoscaling_groups[*].name), null)
  }
}
