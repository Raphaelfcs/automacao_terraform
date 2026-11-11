data "terraform_remote_state" "aws_app" {
  backend = "s3"
  config = {
    bucket = var.estado_aws_bucket
    key    = "docs-pacientes/${var.ambiente}/aws/app/terraform.tfstate"
    region = "sa-east-1"
  }
}

data "terraform_remote_state" "gcp_app" {
  backend = "gcs"
  config = {
    bucket = var.estado_gcp_bucket
    prefix = "docs-pacientes/${var.ambiente}/gcp/app"
  }
}

# Entrada única: app.<domínio> responde pelas duas nuvens (registros ponderados com health check).
# Também publica o CNAME que autoriza o certificado do Load Balancer do GCP. Último root a aplicar.

module "alertas" {
  source      = "../../../../../aws/sns-topic"
  providers   = { aws = aws.us_east_1 }
  name_prefix = "${local.nome}-dns"
  topic_names = ["alertas"]
  subscriptions = {
    alertas = [for e in var.emails_alerta : { protocol = "email", endpoint = e }]
  }
  publisher_services = ["cloudwatch.amazonaws.com"]
  tags               = local.tags
}

module "app" {
  source      = "../../../../../aws/route53-health-routing"
  providers   = { aws = aws.us_east_1 }
  zone_id     = var.zona_dns_id
  record_name = var.dominio_app
  endpoints = {
    aws = {
      weight      = var.peso_aws
      alias       = { name = local.aws_app.cloudfront_dominio, zone_id = "Z2FDTNDATAQYW2" } # zona fixa de toda distribuição CloudFront
      health_fqdn = local.aws_app.cloudfront_dominio
    }
    gcp = {
      weight      = var.peso_gcp
      ips         = [local.gcp_app.lb_ip]
      health_fqdn = var.dominio_app
      health_ip   = local.gcp_app.lb_ip
    }
  }
  alarm_topic_arn = module.alertas.topic_arns["alertas"]
  tags            = local.tags
}

module "registros" {
  source  = "../../../../../aws/route53-records"
  zone_id = var.zona_dns_id
  records = {
    certificado-gcp = {
      name   = local.gcp_app.registro_autorizacao_dns.name
      type   = local.gcp_app.registro_autorizacao_dns.type
      values = [local.gcp_app.registro_autorizacao_dns.data]
    }
  }
}
