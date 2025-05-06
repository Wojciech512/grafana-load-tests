resource "google_cloud_run_v2_service" "django" {
  name     = "django-app"
  location = var.region

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/my-registry/django-app:latest"

      ports {
        container_port = 8000
      }

      env {
        name  = "DATABASE_URL"
        value = "postgresql://postgres:${var.db_password}@/postgres?host=/cloudsql/${google_sql_database_instance.postgres.connection_name}&sslmode=disable"
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
    type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

resource "google_cloud_run_service_iam_member" "django_invoker" {
  service  = google_cloud_run_v2_service.django.name
  location = google_cloud_run_v2_service.django.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
