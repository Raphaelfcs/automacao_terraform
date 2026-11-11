locals {
  # Nomes globais únicos: <project>-<app>-<env>-site|logs (máx. 63 caracteres)
  name_prefix      = substr("${var.project_id}-${var.app_name}-${var.environment}", 0, 57)
  site_bucket_name = "${local.name_prefix}-site"
  logs_bucket_name = "${local.name_prefix}-logs"

  log_object_prefix = "${var.environment}/${local.site_bucket_name}"

  labels = merge(
    {
      app         = var.app_name
      environment = var.environment
      managed-by  = "terraform"
      module      = "static-site"
    },
    var.labels,
  )

  # Arquivos do build a enviar (vazio se site_source_dir = null)
  site_files = var.site_source_dir == null ? toset([]) : fileset(var.site_source_dir, "**")

  mime_types = {
    html        = "text/html; charset=utf-8"
    css         = "text/css; charset=utf-8"
    js          = "application/javascript; charset=utf-8"
    mjs         = "application/javascript; charset=utf-8"
    json        = "application/json"
    map         = "application/json"
    txt         = "text/plain; charset=utf-8"
    svg         = "image/svg+xml"
    png         = "image/png"
    jpg         = "image/jpeg"
    jpeg        = "image/jpeg"
    gif         = "image/gif"
    webp        = "image/webp"
    ico         = "image/x-icon"
    woff        = "font/woff"
    woff2       = "font/woff2"
    webmanifest = "application/manifest+json"
  }
}
