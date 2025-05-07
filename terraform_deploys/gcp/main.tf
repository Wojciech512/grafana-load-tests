resource "google_project" "current" {
  project_id = var.repository_id
  name       = var.project_name
}
