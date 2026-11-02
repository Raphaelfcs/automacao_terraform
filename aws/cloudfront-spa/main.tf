# SPA estática: S3 privado atrás de CloudFront com Origin Access Control (o bucket não é
# público; o único caminho até os objetos é a distribuição), rewrite de rotas por CloudFront
# Function, cabeçalhos de segurança, WAF opcional e origem de API opcional (ALB público ou
# ALB interno via CloudFront VPC origin) para servir front e API no mesmo domínio.

resource "aws_s3_bucket" "this" {
  bucket        = "${var.name_prefix}-${var.app_name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = var.force_destroy

  tags = merge(var.tags, { Name = "${var.name_prefix}-${var.app_name}" })
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.name_prefix}-${var.app_name}"
  description                       = "OAC de ${var.app_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ALB interno como origem. O CloudFront cria ENIs nas subnets do ALB e o SG
# gerenciado `CloudFront-VPCOrigins-Service-SG`; a regra de entrada no SG do ALB referencia esse
# SG e fica na raiz que e dona do ALB.
resource "aws_cloudfront_vpc_origin" "api" {
  count = local.has_vpc_api_origin ? 1 : 0

  vpc_origin_endpoint_config {
    name                   = "${var.name_prefix}-${var.app_name}-api"
    arn                    = var.api_vpc_origin_arn
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = var.api_vpc_origin_protocol_policy

    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-${var.app_name}-api" })
}

resource "aws_cloudfront_function" "spa_rewrite" {
  name    = "${var.name_prefix}-${var.app_name}-spa-rewrite"
  runtime = "cloudfront-js-2.0"
  comment = "Reescreve rotas do react-router para /index.html"
  publish = true
  code    = file("${path.module}/functions/spa-rewrite.js")
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "SPA ${var.app_name} (${var.name_prefix})"
  aliases             = var.aliases
  default_root_object = "index.html"
  price_class         = var.price_class
  web_acl_id          = var.web_acl_id

  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id                = "s3-${var.app_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  dynamic "origin" {
    for_each = local.has_custom_api_origin ? [var.api_origin_domain] : []

    content {
      domain_name = origin.value
      origin_id   = "api-${var.app_name}"

      custom_origin_config {
        http_port  = 80
        https_port = 443
        # O load balancer interno nao tem certificado proprio; o TLS termina no
        # CloudFront e a perna interna trafega dentro da VPC.
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  dynamic "origin" {
    for_each = local.has_vpc_api_origin ? [aws_cloudfront_vpc_origin.api[0]] : []

    content {
      # O dominio da origem VPC e o DNS do proprio ALB interno (privado; so as ENIs do
      # CloudFront dentro da VPC o resolvem e alcancam).
      domain_name = var.api_vpc_origin_domain
      origin_id   = "api-${var.app_name}"

      vpc_origin_config {
        vpc_origin_id = origin.value.id
      }
    }
  }

  # Chamadas de API não são cacheáveis e precisam do metodo, do corpo e do cabecalho
  # Authorization intactos ate o backend.
  dynamic "ordered_cache_behavior" {
    for_each = local.has_api_origin ? var.api_path_patterns : []

    content {
      path_pattern           = ordered_cache_behavior.value
      target_origin_id       = "api-${var.app_name}"
      viewer_protocol_policy = "https-only"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true

      # Politicas gerenciadas: CachingDisabled e AllViewerExceptHostHeader — esta ultima
      # encaminha Authorization e demais cabecalhos, preservando o Host da origem.
      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      origin_request_policy_id   = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-${var.app_name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # Politicas gerenciadas da AWS: CachingOptimized e a origem imutavel dos assets
    # com hash no nome.
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.spa_rewrite.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Com o certificado PADRÃO do CloudFront (*.cloudfront.net) a AWS fixa o mínimo em TLSv1 e
  # ignora outro valor (declarar TLSv1.2_2021 gera diff perpétuo). TLS 1.2+ exige domínio próprio
  # com certificado ACM em us-east-1 (var.acm_certificate_arn).
  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == null
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.acm_certificate_arn == null ? null : "sni-only"
    minimum_protocol_version       = var.acm_certificate_arn == null ? "TLSv1" : "TLSv1.2_2021"
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-${var.app_name}" })
}

# Publicacao do dist/: cada arquivo do build vira um objeto. E o equivalente
# Terraform do BucketDeployment — sem isso o bucket fica vazio e o CloudFront
# responde AccessDenied.
resource "aws_s3_object" "dist" {
  for_each = local.dist_files

  bucket       = aws_s3_bucket.this.id
  key          = each.value
  source       = "${var.dist_path}/${each.value}"
  etag         = filemd5("${var.dist_path}/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$|$", each.value), "application/octet-stream")

  # O index nao pode ser cacheado: e ele que aponta para o bundle novo a cada deploy.
  cache_control = each.value == "index.html" ? "no-cache, no-store, must-revalidate" : "public, max-age=31536000, immutable"

  tags = var.tags
}

data "aws_caller_identity" "current" {}
