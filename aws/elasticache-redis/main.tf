# ElastiCache (Valkey ou Redis) em subnets privadas, cifrado em repouso e em trânsito.
# Com réplicas > 0 liga failover automático e Multi-AZ.

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name_prefix}-cache"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, { Name = "${var.name_prefix}-cache" })
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${var.name_prefix}-cache"
  # Só ASCII: a API do ElastiCache recusa travessão (U+2014) como "non-printable character".
  description = "Cache ${var.name_prefix}"

  # Valkey por padrão: o Redis OSS na ElastiCache ficou congelado na 7.1 após a mudança
  # de licença; o Valkey é compatível no protocolo e custa ~20% menos por nó.
  engine         = var.engine
  engine_version = var.engine_version
  node_type      = var.node_type
  port           = var.port

  num_cache_clusters         = var.replica_count + 1
  automatic_failover_enabled = var.replica_count > 0
  multi_az_enabled           = var.replica_count > 0

  subnet_group_name           = aws_elasticache_subnet_group.this.name
  preferred_cache_cluster_azs = var.preferred_cache_cluster_azs
  security_group_ids          = [aws_security_group.this.id]

  at_rest_encryption_enabled = true
  kms_key_id                 = var.kms_key_arn
  transit_encryption_enabled = true

  apply_immediately        = var.apply_immediately
  snapshot_retention_limit = var.snapshot_retention_limit
  maintenance_window       = var.maintenance_window

  tags = merge(var.tags, { Name = "${var.name_prefix}-cache" })
}
