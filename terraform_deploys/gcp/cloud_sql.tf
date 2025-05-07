resource "google_sql_database_instance" "postgres" {
  name             = "praca-magisterska-db"
  database_version = "POSTGRES_16"
  region           = var.region

  settings {
    tier = "db-perf-optimized-N-2"

    ip_configuration {
      ipv4_enabled = true
      require_ssl  = false

      authorized_networks {
        name  = "all"
        value = "0.0.0.0/0"
      }
    }

  }
}

resource "google_sql_user" "postgres_user" {
  name     = var.GOOGLE_POSTGRESQL_NAME
  instance = google_sql_database_instance.postgres.name
  password = var.GOOGLE_POSTGRESQL_PASSWORD
}
