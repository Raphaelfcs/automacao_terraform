# Cluster Amazon Aurora (MySQL ou PostgreSQL), provisionado ou Serverless v2, em subnets
# privadas, cifrado com KMS, senha master gerenciada pela AWS (Secrets Manager), réplicas
# de leitura com autoscaling opcional e logs exportados ao CloudWatch.

resource "aws_db_subnet_group" "this" {
  name        = var.name
  description = "Aurora ${var.name}"
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_rds_cluster_parameter_group" "this" {
  name        = "${var.name}-cluster"
  family      = var.parameter_group_family
  description = "Parametros do cluster ${var.name}"

  dynamic "parameter" {
    for_each = merge(local.default_cluster_parameters, var.cluster_parameters)
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

resource "aws_rds_cluster" "this" {
  cluster_identifier = var.name
  engine             = var.engine
  engine_mode        = "provisioned"
  engine_version     = var.engine_version

  database_name                 = var.database_name
  master_username               = var.master_username
  manage_master_user_password   = true
  master_user_secret_kms_key_id = var.kms_key_arn

  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name
  port                            = local.port

  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.backup_window
  preferred_maintenance_window = var.maintenance_window
  copy_tags_to_snapshot        = true
  deletion_protection          = var.deletion_protection
  skip_final_snapshot          = !var.final_snapshot
  final_snapshot_identifier    = var.final_snapshot ? "${var.name}-final" : null

  iam_database_authentication_enabled = var.iam_database_authentication
  enabled_cloudwatch_logs_exports     = local.log_exports[var.engine]
  backtrack_window                    = var.engine == "aurora-mysql" ? var.backtrack_window_hours * 3600 : null

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.serverless_v2 == null ? [] : [var.serverless_v2]
    content {
      min_capacity = serverlessv2_scaling_configuration.value.min_capacity
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
    }
  }

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_rds_cluster_instance" "this" {
  for_each = var.instances

  identifier         = "${var.name}-${each.key}"
  cluster_identifier = aws_rds_cluster.this.id
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  # Serverless v2 usa a classe especial db.serverless.
  instance_class = var.serverless_v2 == null ? each.value.instance_class : "db.serverless"
  promotion_tier = each.value.promotion_tier

  db_subnet_group_name = aws_db_subnet_group.this.name
  publicly_accessible  = false

  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_enabled ? var.kms_key_arn : null
  monitoring_interval             = var.enhanced_monitoring_interval
  monitoring_role_arn             = var.enhanced_monitoring_interval > 0 ? aws_iam_role.monitoring[0].arn : null
  auto_minor_version_upgrade      = true

  tags = merge(var.tags, { Name = "${var.name}-${each.key}" })
}
