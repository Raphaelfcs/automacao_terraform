variable "cluster_name" {
  description = "Cluster cujos node groups entram na janela."
  type        = string
}

variable "node_group_names" {
  description = "Node groups da janela, por chave estavel (tipicamente a AZ). O NOME COMPLETO do node group, como o modulo eks o cria: `<cluster>-<chave do pool>`."
  type        = map(string)
}

variable "enabled" {
  description = "Liga as acoes agendadas. FALSE deixa o cluster 24x7 — e o que se quer quando o ambiente estiver em homologacao com janela noturna."
  type        = bool
  default     = true
}

variable "up_cron" {
  description = "Cron da subida, no fuso de `timezone`. Formato do autoscaling: `minuto hora dia mes dia-da-semana`."
  type        = string
  default     = "0 8 * * 1-5"

  validation {
    condition     = can(regex("^[0-9*,/-]+ [0-9*,/-]+ [0-9*,/?-]+ [0-9A-Za-z*,/-]+ [0-9A-Za-z*,/?-]+$", var.up_cron))
    error_message = "up_cron tem de ter cinco campos: `minuto hora dia mes dia-da-semana`. Sem segundos e sem ano — este nao e o formato do EventBridge."
  }
}

variable "down_cron" {
  description = "Cron da descida. A descida de sexta e o que zera o fim de semana: nao existe acao de sabado, a proxima subida e so na segunda."
  type        = string
  default     = "45 23 * * 1-5"

  validation {
    condition     = can(regex("^[0-9*,/-]+ [0-9*,/-]+ [0-9*,/?-]+ [0-9A-Za-z*,/-]+ [0-9A-Za-z*,/?-]+$", var.down_cron))
    error_message = "down_cron tem de ter cinco campos: `minuto hora dia mes dia-da-semana`."
  }
}

variable "timezone" {
  description = "Fuso das acoes. 🔴 Nome IANA, nunca offset: sobrevive a mudanca de regra de horario de verao sem ninguem reaplicar. Sem este campo a AWS interpreta o cron em UTC, e a janela sai tres horas deslocada."
  type        = string
  default     = "America/Sao_Paulo"

  validation {
    condition     = can(regex("^[A-Za-z]+/[A-Za-z_]+$", var.timezone))
    error_message = "timezone tem de ser nome IANA, como America/Sao_Paulo, nao offset como -03:00."
  }
}

variable "up_min_size" {
  description = "Minimo restaurado na subida, POR node group."
  type        = number
  default     = 1
}

variable "up_desired_capacity" {
  description = "Desejado restaurado na subida, POR node group."
  type        = number
  default     = 1
}

variable "up_max_size" {
  description = "Teto restaurado na subida, POR node group."
  type        = number
  default     = 2
}
