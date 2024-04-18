variable "image_name" {
  description = "Image name"
}

variable "image_version" {
  description = "Image version"
}

variable "env_toggle" {
  default = "dev"
}

variable "backend_state" {
  default = "./dev.tfvars"
}

variable "app_config" {
  type = map(
    object({
      project_id                     = string
      GOOGLE_APPLICATION_CREDENTIALS = string
      credentials_file               = string
      region                         = string
      cluster_name                   = string
      namespace                      = string
      service_name                   = string
      workspace_config               = string
    })
  )
}
