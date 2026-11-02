output "topic" {
  value = google_pubsub_topic.orders.name
}

output "function" {
  value = google_cloudfunctions2_function.notify.name
}
