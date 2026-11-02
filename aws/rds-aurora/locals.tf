locals {
  port = var.engine == "aurora-mysql" ? 3306 : 5432

  log_exports = {
    "aurora-mysql"      = ["audit", "error", "slowquery"]
    "aurora-postgresql" = ["postgresql"]
  }

  default_cluster_parameters = var.engine == "aurora-mysql" ? {
    require_secure_transport = "ON"
    character_set_server     = "utf8mb4"
    } : {
    "rds.force_ssl" = "1"
  }
}
