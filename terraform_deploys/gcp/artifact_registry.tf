resource "google_artifact_registry_repository" "docker" {
  provider      = google
  project       = google_project.this.project_id
  location      = var.project_region
  repository_id = "praca-magisterska-artifact-registry"
  format        = "DOCKER"

  depends_on = [
    google_project_service.billing_api,
    google_project_service.enabled_apis["artifactregistry.googleapis.com"]
  ]
}
