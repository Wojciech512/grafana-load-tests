locals {
  apis = [
    "sqladmin.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
  ]
}

resource "google_project_service" "enabled_apis" {
  for_each = toset(local.apis)
  project  = google_project.this.project_id
  service  = each.key

  depends_on = [
    google_billing_project_info.this
  ]
}
