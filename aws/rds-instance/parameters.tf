# Grupo de parâmetros com TLS obrigatório e UTF-8 completo.
resource "aws_db_parameter_group" "this" {
  name = "${var.name_prefix}-${var.engine}"
  # Família derivada dos dois primeiros segmentos da versão ("8.4.3" -> mysql8.4;
  # "16.4" -> postgres16). Fixar ".0" quebrava o apply com engine 8.4 ("mysql8.0" errado).
  family      = var.engine == "mysql" ? "mysql${join(".", slice(split(".", var.engine_version), 0, 2))}" : "postgres${split(".", var.engine_version)[0]}"
  description = "Parametros ${var.engine} de ${var.name_prefix}"

  dynamic "parameter" {
    for_each = merge(local.default_parameters[var.engine], var.extra_parameters)
    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
