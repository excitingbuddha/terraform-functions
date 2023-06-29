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
  bucket_name          = "deployments/${var.function_name}-source"
  location             = var.fun_location
  bucket_prefix_length = var.bucket_prefix_length
  project_id           = var.fun_project_id
  source_code          = module.archive.source
  output_location      = module.archive.output_path
}

resource "google_service_account" "default" {
  account_id   = var.service_account.account_id
  display_name = var.service_account.display_name
  project      = var.fun_project_id
}

resource "google_cloudfunctions2_function" "default" {
  name        = var.function_name
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
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.default.email
  }
}

output "function_location" {
  value       = google_cloudfunctions2_function.default.location
  description = "Url of the cloudfunction"
}