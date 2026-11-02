# Amazon MSK (Kafka gerenciado) com autenticação SASL/IAM, TLS em trânsito, KMS em repouso
# e logs de broker no CloudWatch. Criação automática de tópicos desligada: tópicos são
# declarados pelos donos, não criados por acidente no primeiro produce.

resource "aws_cloudwatch_log_group" "broker" {
  name              = "/aws/msk/${var.name_prefix}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = var.tags
}

resource "aws_msk_configuration" "this" {
  name           = "${var.name_prefix}-msk"
  kafka_versions = [var.kafka_version]
  description    = "Configuracao do MSK ${var.name_prefix}"

  server_properties = <<-PROPERTIES
    auto.create.topics.enable=false
    default.replication.factor=${min(local.broker_nodes, 3)}
    min.insync.replicas=${min(local.broker_nodes, 2)}
    num.partitions=${var.default_partitions}
    log.retention.hours=${var.log_retention_hours}
  PROPERTIES

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_msk_cluster" "this" {
  cluster_name           = "${var.name_prefix}-msk"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = local.broker_nodes

  broker_node_group_info {
    instance_type   = var.broker_instance_type
    client_subnets  = var.subnet_ids
    security_groups = [aws_security_group.this.id]

    storage_info {
      ebs_storage_info {
        volume_size = var.broker_volume_size
      }
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.this.arn
    revision = aws_msk_configuration.this.latest_revision
  }

  client_authentication {
    sasl {
      iam = true
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.kms_key_arn

    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  enhanced_monitoring = var.enhanced_monitoring

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.broker.name
      }
    }
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-msk" })
}
