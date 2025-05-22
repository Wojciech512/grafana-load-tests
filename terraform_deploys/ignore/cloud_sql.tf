# resource "google_sql_database_instance" "postgres" {
#   name             = "praca-magisterska-db"
#   project          = google_project.this.project_id
#   database_version = "POSTGRES_16"
#   region           = var.project_region
#
#   depends_on = [
#     google_project_service.billing_api,
#     google_project_service.enabled_apis["sqladmin.googleapis.com"]
#   ]
#
#   settings {
#     tier = "db-perf-optimized-N-2"
#
#     insights_config {
#       query_insights_enabled  = true
#       query_plans_per_minute  = 5
#       query_string_length     = 1024
#       record_application_tags = false
#       record_client_address   = false
#     }
#
#     ip_configuration {
#       ipv4_enabled = true
#
#       authorized_networks {
#         name  = "all"
#         value = "0.0.0.0/0"
#       }
#
#       ssl_mode = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
#     }
#   }
# }
#
# resource "google_sql_user" "postgres_user" {
#   name     = var.GOOGLE_POSTGRESQL_NAME
#   instance = google_sql_database_instance.postgres.name
#   password = var.GOOGLE_POSTGRESQL_PASSWORD
# }
