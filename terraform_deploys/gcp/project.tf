resource "google_project" "this" {
  project_id      = var.project_id
  name            = var.project_name
  billing_account = var.billing_account
}

resource "google_project_service" "billing_api" {
  project = google_project.this.project_id
  service = "cloudbilling.googleapis.com"

  depends_on = [
    google_billing_project_info.this
  ]
}

resource "google_billing_project_info" "this" {
  project         = google_project.this.project_id
  billing_account = var.billing_account
}

resource "google_project_service" "monitoring" {
  project = google_project.this.project_id
  service = "monitoring.googleapis.com"
}
