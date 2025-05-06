resource "google_cloud_run_v2_service" "exporter" {
  name     = "praca-magisterska-postgres-exporter"
  location = var.region

  template {
    containers {
      image = "wrouesnel/postgres_exporter"

      ports {
        container_port = 9187
      }
      env {
        name  = "DATA_SOURCE_NAME"
        value = "postgresql://postgres:${var.GOOGLE_PASSWORD}@/postgres?host=/cloudsql/${google_sql_database_instance.postgres.connection_name}&sslmode=disable"
      }
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.postgres.connection_name]
      }
    }
    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

resource "google_cloud_run_service_iam_member" "exporter_invoker" {
  service  = google_cloud_run_v2_service.exporter.name
  location = google_cloud_run_v2_service.exporter.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
