output "network_id" {
  value = google_compute_network.vpc.id
}

output "network_self_link" {
  value = google_compute_network.vpc.self_link
}

output "subnet_self_link" {
  value = google_compute_subnetwork.gke.self_link
}

output "pods_range_name" {
  value = local.pods_range_name
}

output "services_range_name" {
  value = local.services_range_name
}

output "psa_connection" {
  value = google_service_networking_connection.psa.id
}
