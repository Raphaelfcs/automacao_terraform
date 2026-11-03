# RDS (MySQL ou PostgreSQL) em subnets privadas, cifrado com KMS, sem acesso público.
# A senha do usuário master é gerenciada pela AWS (manage_master_user_password) e fica
# apenas no Secrets Manager: não existe senha em variável, em state legível ou em repositório.

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-${var.engine}"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, { Name = "${var.name_prefix}-${var.engine}" })
}

resource "aws_db_instance" "this" {
  identifier     = "${var.name_prefix}-${var.engine}"
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage == null ? var.allocated_storage * 2 : var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  db_name                       = var.database_name
  username                      = var.master_username
  manage_master_user_password   = true
  master_user_secret_kms_key_id = var.kms_key_arn

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name   = aws_db_parameter_group.this.name
  publicly_accessible    = false

  multi_az = var.multi_az
  # AZ fixa só quando informada (útil quando há orçamento de IP por subnet). null = AWS escolhe.
  availability_zone = var.multi_az ? null : var.availability_zone

  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  copy_tags_to_snapshot     = true
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = !var.final_snapshot
  final_snapshot_identifier = var.final_snapshot ? "${var.name_prefix}-${var.engine}-final" : null

  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_enabled ? var.kms_key_arn : null
  monitoring_interval             = var.enhanced_monitoring_interval
  monitoring_role_arn             = var.enhanced_monitoring_interval > 0 ? aws_iam_role.monitoring[0].arn : null

  auto_minor_version_upgrade          = true
  enabled_cloudwatch_logs_exports     = local.log_exports[var.engine]
  iam_database_authentication_enabled = var.iam_database_authentication

  tags = merge(var.tags, { Name = "${var.name_prefix}-${var.engine}" })
}
