terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.34.0"
    }
  }
}

resource "random_id" "bucket_prefix" {
  byte_length = var.bucket_prefix_length
}

module "archive" {
  source     = "git::https://github.com/betikake/terraform-archive"
  source_dir = var.source_dir
}

module "bucket" {
  source               = "git::https://github.com/betikake/terraform-bucket"
  bucket_name          = var.source_bucket_name
  location             = var.fun_location
  project_id           = var.fun_project_id
  source_code          = module.archive.source
  output_location      = module.archive.output_path
  function_name        = replace(var.function_name,"/[0-9A-Za-z_-]*//", "")
}

resource "google_service_account" "default" {
  account_id   = replace(lower(var.service_account.account_id),"/[0-9A-Za-z_-]*//", "")
  display_name = replace(lower(var.service_account.display_name),"/[0-9A-Za-z_-]*//", "")
  project      = var.fun_project_id
}


//permission
resource "google_project_iam_member" "permissions_am" {
  project  = var.fun_project_id
  for_each = toset([
    "roles/bigquery.dataEditor",
    "roles/cloudfunctions.invoker",
    "roles/run.invoker",
    "roles/cloudsql.admin",
    "roles/cloudsql.client",
    "roles/cloudsql.editor",
    "roles/logging.admin",
    "roles/logging.logWriter",
    "roles/pubsub.publisher",
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.default.email}"
}

resource "google_cloudfunctions2_function" "default" {
  name        = replace(lower(var.function_name),"/[0-9A-Za-z_-]*//", "")
  location    = var.region
  description = var.description
  project     = var.fun_project_id

  build_config {
    runtime               = var.run_time
    entry_point           = var.entry_point
    environment_variables = {
      BUILD_CONFIG_TEST = "build_test"
    }
    source {
      storage_source {
        bucket = module.bucket.bucket_name
        object = module.bucket.bucket_object
      }
    }
  }

  service_config {
    max_instance_count             = var.max_instance
    min_instance_count             = var.min_instance
    available_memory               = var.available_memory
    timeout_seconds                = var.timeout
    environment_variables          = var.environment_variables
    vpc_connector                  = var.vpc_connector
   // ingress_settings               = var.ingress_settings
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.default.email
    vpc_connector_egress_settings  = var.vpc_connector_egress_settings
  }

  labels = {
    version-crc32c = lower(replace(module.bucket.crc32c, "/\\W+/", ""))
  }
}

data "google_iam_policy" "private" {
  binding {
    role    = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "public" {
  location = google_cloudfunctions2_function.default.location
  project  = google_cloudfunctions2_function.default.project
  service  = google_cloudfunctions2_function.default.name

  policy_data = data.google_iam_policy.private.policy_data
}

output "function_location" {
  value       = google_cloudfunctions2_function.default.service_config[0].uri
  description = "Url of the cloudfunction"
}
