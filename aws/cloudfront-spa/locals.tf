locals {
  # Extensao -> Content-Type. Sem isso o S3 serve tudo como application/octet-stream
  # e o browser recusa executar o bundle.
  mime_types = {
    ".html"        = "text/html"
    ".css"         = "text/css"
    ".js"          = "text/javascript"
    ".mjs"         = "text/javascript"
    ".json"        = "application/json"
    ".map"         = "application/json"
    ".svg"         = "image/svg+xml"
    ".png"         = "image/png"
    ".jpg"         = "image/jpeg"
    ".jpeg"        = "image/jpeg"
    ".gif"         = "image/gif"
    ".ico"         = "image/x-icon"
    ".webp"        = "image/webp"
    ".woff"        = "font/woff"
    ".woff2"       = "font/woff2"
    ".txt"         = "text/plain"
    ".webmanifest" = "application/manifest+json"
  }

  # Source map revela o código-fonte a quem abrir o DevTools: com publish_source_maps = false
  # nenhum *.map vira objeto.
  all_dist_files = fileexists("${var.dist_path}/index.html") ? fileset(var.dist_path, "**") : toset([])
  dist_files     = var.publish_source_maps ? local.all_dist_files : toset([for f in local.all_dist_files : f if !endswith(f, ".map")])

  # Duas formas de chegar à API, mutuamente exclusivas (validação em variables.tf):
  #  - custom: hostname de load balancer PÚBLICO;
  #  - vpc: ALB INTERNO alcançado por CloudFront VPC origin, sem nada público na VPC.
  has_custom_api_origin = trimspace(var.api_origin_domain) != ""
  # Flag e nao "ARN preenchido": o ARN do ALB e desconhecido no plan quando o ALB nasce no mesmo apply.
  has_vpc_api_origin = var.api_vpc_origin_enabled
  has_api_origin     = local.has_custom_api_origin || local.has_vpc_api_origin
}
