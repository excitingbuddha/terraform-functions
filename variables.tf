variable "fun_location" {
  default = "eu"
}

variable "fun_project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

variable "bucket_prefix_length" {
  default = 10
}

variable "max_instance" {
  default = 1
}

variable "timeout" {
  default = 60
}

variable "function_name" {}

variable "description" {
  type = string
}

variable "min_instance" {
  default = 1
}

variable "run_time" {
  default = "go120"
  type    = string
}

variable "available_memory" {
  default = "128Mi"
  type    = string
}

variable "max_instance_request_concurrency" {
  default = 1
}
variable "entry_point" {
  type = string
}

variable "region" {
  description = "The region where the Cloud Function will be deployed."
  type        = string
}

variable "service_account_email" {
  description = "The email account of the service account to run as"
  type        = string
}

variable "vpc_connector" {
  description = "The name of the VPC connector to associate with the Cloud Function."
  type        = string
}

variable "source_dir" {
  description = "The directory containing the function source code."
  type        = string
}

variable "environment_variables" {
  type    = map(string)
  default = {
    BUILD_CONFIG_TEST   = "build_test"
    BUILD_CONFIG_TEST_2 = "build_test"
  }
}

variable "source_bucket_name" {
  default = "betika-deployments-source"
  type    = string
}

variable "service_mesh_name" {
  default = ""
  type    = string
}

variable "ingress_settings" {
  //default = "ALLOW_INTERNAL_ONLY"
  default = "ALLOW_ALL"
}

variable "vpc_connector_egress_settings" {
  default = "ALL_TRAFFIC"
}

variable "available_cpu" {
  default = "1"
  type    = string
}
