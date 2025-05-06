resource "google_sql_database_instance" "postgres" {
  name             = "terraform-db"
  database_version = "POSTGRES_16"
  region           = var.region
  settings {
    tier = "db-perf-optimized-N-2"
  }
}


resource "google_sql_user" "postgres_user" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}
