locals {
  port = var.engine == "mysql" ? 3306 : 5432

  log_exports = {
    mysql    = ["error", "slowquery"]
    postgres = ["postgresql", "upgrade"]
  }

  default_parameters = {
    mysql = {
      # "1", e não "ON": o RDS normaliza o booleano e devolve "1" no state; "ON" gera diff perpétuo.
      require_secure_transport = "1"
      character_set_server     = "utf8mb4"
      collation_server         = "utf8mb4_0900_ai_ci"
    }
    postgres = {
      "rds.force_ssl"            = "1"
      log_min_duration_statement = "1000"
    }
  }
}
