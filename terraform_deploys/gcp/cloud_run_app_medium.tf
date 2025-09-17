resource "google_cloud_run_v2_service" "cloud_run_app_medium" {
  name                = "praca-magisterska-django-app-medium"
  location            = var.project_region
  deletion_protection = false
  project             = google_project.this.project_id

  depends_on = [
    google_project_service.billing_api,
    google_project_service.enabled_apis["run.googleapis.com"],
  ]

  template {
    service_account = google_service_account.proxy["medium"].email

    containers {
      image = "${var.project_region}-docker.pkg.dev/${var.project_id}/${var.repository_id}/ecommerce-app:latest"

      ports {
        container_port = 8000
      }

      resources {
        limits = {
          cpu    = "2"
          memory = "3584Mi"
        }
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
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
        value = "/cloudsql/${google_sql_database_instance.postgres_medium.connection_name}"
      }
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [
          google_sql_database_instance.postgres_medium.connection_name,
        ]
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

resource "google_cloud_run_service_iam_member" "django_invoker_srednia" {
  location = var.project_region
  project  = google_project.this.project_id
  service  = google_cloud_run_v2_service.cloud_run_app_medium.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
