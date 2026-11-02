output "db_private_ip" {
  value = google_sql_database_instance.pg.private_ip_address
}

output "db_secret_id" {
  value = google_secret_manager_secret.db.secret_id
}

output "connection_name" {
  value = google_sql_database_instance.pg.connection_name
}
