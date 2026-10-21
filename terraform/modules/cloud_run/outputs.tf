output "service_name" {
  description = "Cloud Run service name."
  value       = google_cloud_run_v2_service.service.name
}

output "service_uri" {
  description = "Default Cloud Run service URI."
  value       = google_cloud_run_v2_service.service.uri
}

output "latest_ready_revision" {
  description = "Latest ready revision name."
  value       = google_cloud_run_v2_service.service.latest_ready_revision
}
