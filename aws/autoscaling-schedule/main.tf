data "aws_eks_node_group" "pool" {
  for_each = var.enabled ? var.node_group_names : {}

  cluster_name    = var.cluster_name
  node_group_name = each.value
}

resource "aws_autoscaling_schedule" "up" {
  for_each = var.enabled ? var.node_group_names : {}

  scheduled_action_name  = "${each.value}-scale-up"
  autoscaling_group_name = local.asg_por_pool[each.key]

  recurrence = var.up_cron
  time_zone  = var.timezone

  # Os mesmos valores do dimensionamento normal, recebidos por variavel: a subida devolve o
  # grupo ao que a raiz define, sem duplicar numero em outro lugar.
  min_size         = var.up_min_size
  desired_capacity = var.up_desired_capacity
  max_size         = var.up_max_size

  # ── `ignore_changes` no nome do ASG — evita um deadlock JA OBSERVADO ─────
  #
  #  Isto nao e precaucao teorica. Aconteceu em 2026-10-14 no cluster de monitoria do
  # repositorio de referencia, e a sequencia foi:
  #
  #   1. a acao da noite pos desired = 0 no ASG;
  #   2. o terraform quis restaurar min = 1, gerando mudanca pendente no node group;
  #   3. o data source acima, que tem depends_on no node group, virou "known after apply";
  #   4. valor desconhecido em atributo que forca replace DESTRUIU as quatro acoes agendadas,
  #      e o update do node group falhou porque a AWS recusa `min > desired`;
  #   5. fim do apply: cluster com 0 nos e sem agendamento — nao subiria no dia seguinte.
  #
  # O nome do ASG nao muda na vida de um node group: so mudaria se o node group fosse
  # recriado, e ai estas acoes precisariam de recriacao explicita de qualquer forma.
  #
  #  A outra metade da correcao esta na raiz, nao aqui: o node group nasce com
  # `min_size = 0`, para que o terraform nunca tenha min pendente para restaurar. As duas
  # juntas; `ignore_changes` sozinho so adia o deadlock.
  lifecycle {
    ignore_changes = [autoscaling_group_name]
  }
}

resource "aws_autoscaling_schedule" "down" {
  for_each = var.enabled ? var.node_group_names : {}

  scheduled_action_name  = "${each.value}-scale-down"
  autoscaling_group_name = local.asg_por_pool[each.key]

  recurrence = var.down_cron
  time_zone  = var.timezone

  min_size         = 0
  desired_capacity = 0
  max_size         = 0

  # Mesmo motivo do recurso acima — ver o comentario do deadlock de 2026-10-14.
  lifecycle {
    ignore_changes = [autoscaling_group_name]
  }
}

# Guardas de plan. `terraform_data` nao cria nada na AWS.
resource "terraform_data" "guardas" {
  input = {
    pools = sort(values(var.node_group_names))
    up    = var.up_cron
    down  = var.down_cron
  }

  lifecycle {
    #  A guarda que protege o fim de semana.
    #
    # "Zerado no fim de semana" nao vem de uma acao de sabado: vem de a descida de SEXTA nao
    # ter subida depois dela ate segunda. Se a subida rodar todos os dias (`* * *`) e a
    # descida so em dias uteis, o cluster sobe sabado e domingo as 08:00 e nunca mais desce —
    # dois dias inteiros de no ligado, sem ninguem usando e sem nada no painel indicando.
    #
    # A condicao exige que AMBOS os crons tenham o mesmo campo de dia-da-semana.
    precondition {
      condition     = element(split(" ", var.up_cron), 4) == element(split(" ", var.down_cron), 4)
      error_message = "O campo de dia-da-semana difere entre up_cron ('${var.up_cron}') e down_cron ('${var.down_cron}'). Se a subida roda em dia que a descida nao cobre, o cluster fica LIGADO indefinidamente nesse dia — e o fim de semana zerado depende exatamente disso, porque nao ha acao de sabado: o que zera o sabado e a descida de sexta sem subida depois."
    }

    # Subida depois da descida no mesmo dia deixaria o cluster ligado a noite toda.
    precondition {
      condition = (
        tonumber(element(split(" ", var.up_cron), 1)) * 60 + tonumber(element(split(" ", var.up_cron), 0))
        <
        tonumber(element(split(" ", var.down_cron), 1)) * 60 + tonumber(element(split(" ", var.down_cron), 0))
      )
      error_message = "A subida ('${var.up_cron}') nao e anterior a descida ('${var.down_cron}') no mesmo dia. Nesta ordem o cluster liga depois de desligar e fica ligado a noite inteira."
    }

    precondition {
      condition     = !var.enabled || length(var.node_group_names) > 0
      error_message = "enabled = true sem node group nenhum. A janela nao se aplica a nada: provavel erro na descoberta de AZ da raiz."
    }

    #  Esta e avaliada no APPLY, nao no plan: o data source do node group so e lido depois
    # de o node group existir. Sem ela, um node group sem ASG visivel produz
    # `autoscaling_group_name = null` e o erro vira "Missing required argument" num recurso
    # que ninguem relaciona com o nome do pool.
    precondition {
      condition     = !var.enabled || alltrue([for k, v in local.asg_por_pool : v != null])
      error_message = "Algum node group de '${var.cluster_name}' nao devolveu nome de ASG. Confira se os nomes em node_group_names existem de fato: o modulo eks monta `<cluster>-<chave do pool>`, e um nome errado passa pelo plan e falha aqui."
    }

    precondition {
      condition     = var.up_desired_capacity >= var.up_min_size && var.up_desired_capacity <= var.up_max_size
      error_message = "up_desired_capacity (${var.up_desired_capacity}) fora de [${var.up_min_size}, ${var.up_max_size}]. A AWS recusa a acao agendada no APPLY, nao no plan."
    }
  }
}
