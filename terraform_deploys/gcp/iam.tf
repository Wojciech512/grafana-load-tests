locals {
  proxy_configs = {
    minimal = "cloudsql-proxy-minimal-sa"
    medium  = "cloudsql-proxy-medium-sa"
    high    = "cloudsql-proxy-high-sa"
  }
}

# 1. Tworzenie konta serwisowego dla każdego profilu
resource "google_service_account" "proxy" {
  for_each     = local.proxy_configs
  account_id   = each.value
  display_name = "Cloud SQL Auth Proxy (${each.key})"
  project      = google_project.this.project_id
}

# 2. Generowanie klucza dla każdego konta
resource "google_service_account_key" "proxy_key" {
  for_each           = google_service_account.proxy
  service_account_id = each.value.name
}

# 3. Nadawanie roli Cloud SQL Client
resource "google_project_iam_member" "proxy_cloudsql_client" {
  for_each = google_service_account.proxy
  project  = google_project.this.project_id
  role     = "roles/cloudsql.client"
  member   = "serviceAccount:${each.value.email}"
}

# 4. Nadawanie roli Monitoring Viewer
resource "google_project_iam_member" "proxy_monitoring_viewer" {
  for_each = google_service_account.proxy
  project  = google_project.this.project_id
  role     = "roles/monitoring.viewer"
  member   = "serviceAccount:${each.value.email}"
}
