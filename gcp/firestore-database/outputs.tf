output "name" {
  description = "Nome do banco."
  value       = google_firestore_database.this.name
}

output "id" {
  description = "ID do banco (projects/.../databases/...)."
  value       = google_firestore_database.this.id
}
