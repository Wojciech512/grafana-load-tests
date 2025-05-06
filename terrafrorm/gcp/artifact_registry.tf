resource "google_artifact_registry_repository" "docker_registry" {
  provider      = google
  location      = var.region
  repository_id = "praca-magisterska-registry"
  format        = "DOCKER"
}
