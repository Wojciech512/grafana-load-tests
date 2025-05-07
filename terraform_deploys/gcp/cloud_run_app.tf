resource "google_cloud_run_v2_service" "django_public" {
  name     = "praca-magisterska-django-app"
  location = var.region

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}/django-app:latest"

      ports {
        container_port = 8000
      }

      env {
        name  = "DEBUG"
        value = var.DEBUG
      }

      env {
        name  = "ALLOWED_HOSTS"
        value = var.ALLOWED_HOSTS
      }

      env {
        name  = "EMAIL_HOST_USER"
        value = var.EMAIL_HOST_USER
      }

      env {
        name  = "EMAIL_HOST_PASSWORD"
        value = var.EMAIL_HOST_PASSWORD
      }

      env {
        name  = "SECRET_KEY"
        value = var.SECRET_KEY
      }

      env {
        name  = "CSRF_TRUSTED_ORIGINS"
        value = var.CSRF_TRUSTED_ORIGINS
      }

      env {
        name  = "GOOGLE_POSTGRESQL_NAME"
        value = var.GOOGLE_POSTGRESQL_NAME
      }

      env {
        name  = "GOOGLE_POSTGRESQL_USERNAME"
        value = var.GOOGLE_POSTGRESQL_USERNAME
      }

      env {
        name  = "GOOGLE_POSTGRESQL_PASSWORD"
        value = var.GOOGLE_POSTGRESQL_PASSWORD
      }

      env {
        name  = "GOOGLE_POSTGRESQL_HOST"
        value = var.GOOGLE_POSTGRESQL_HOST
      }

      env {
        name  = "GOOGLE_POSTGRESQL_PORT"
        value = var.GOOGLE_POSTGRESQL_PORT
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

resource "google_cloud_run_service_iam_member" "django_invoker" {
  service  = google_cloud_run_v2_service.django_public.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}
