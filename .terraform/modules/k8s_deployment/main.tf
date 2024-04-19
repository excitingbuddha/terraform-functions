# terraform {
#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "= 5.3.0"
#     }
#   }

#   backend "gcs" {
#     path = var.backend_state
#   }
# }
provider "google" {
  project = var.app_config[var.env_toggle].project_id
  region  = var.app_config[var.env_toggle].region
}

data "google_client_config" "provider" {}

data "google_container_cluster" "my_cluster" {
  name     = var.app_config[var.env_toggle].cluster_name
  location = var.app_config[var.env_toggle].region
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
  )
}

/*resource "kubernetes_namespace" "my_namespace" {
  metadata {
    name = var.namespace
  }
}*/

# resource "kubernetes_config_map" "sportsbook_mts_bet_recon_config" {
#   metadata {
#     name      = var.app_config[var.env_toggle].workspace_config
#     namespace = var.app_config[var.env_toggle].namespace
#   }

#   data = {
#     GOOGLE_APPLICATION_CREDENTIALS = "/service-account-key.json"
#   }
# }


resource "kubernetes_deployment" "my_deployment" {
  metadata {
    name      = var.app_config[var.env_toggle].service_name
    namespace = var.app_config[var.env_toggle].namespace
    labels    = {
      service = var.app_config[var.env_toggle].namespace
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.app_config[var.env_toggle].service_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_config[var.env_toggle].service_name
        }
      }

      spec {
        container {
          image = "${var.image_name}@${var.image_version}"
          name  = var.app_config[var.env_toggle].service_name

          env_from {
            config_map_ref {
              name = kubernetes_config_map.sportsbook_mts_bet_recon_config.metadata[0].name
            }
          }
        }
      }
    }
  }
}

