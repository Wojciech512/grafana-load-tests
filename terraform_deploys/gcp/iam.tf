resource "google_service_account" "proxy" {
  account_id   = "cloudsql-proxy-sa"
  display_name = "Cloud SQL Auth Proxy Service Account"
  project      = google_project.this.project_id
}

resource "google_service_account_key" "proxy_key" {
  service_account_id = google_service_account.proxy.name
  keepers = {
    account_id = google_service_account.proxy.account_id
  }
}

resource "google_project_iam_member" "proxy_cloudsql_client" {
  project = google_project.this.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.proxy.email}"
}

resource "google_project_iam_member" "proxy_monitoring_viewer" {
  project = google_project.this.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.proxy.email}"
}
