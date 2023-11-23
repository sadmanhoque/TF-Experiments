# GKE cluster
data "google_container_engine_versions" "gke_version" {
  location = var.region
  version_prefix = "1.27."
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.region

  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  #Enabling autopilot
  enable_autopilot = true
}

#Setting up the ingress for Kubernetes pods
/*resource "kubernetes_ingress" "example_ingress" {
  metadata {
    name = "example-ingress"
  }

  spec {
    backend {
      service_name = "${var.project_id}-app"
      service_port = 3000
    }

    rule {
      http {
        path {
          backend {
            service_name = "${var.project_id}-app"
            service_port = 3000
          }

          path = "/"
        }

        path {
          backend {
            service_name = "${var.project_id}-app"
            service_port = 3000
          }

          path = "/"
        }
      }
    }

    tls {
      secret_name = "tls-secret"
    }
  }
}

#Deploying the service
resource "kubernetes_service_v1" "example" {
  metadata {
    name = "${var.project_id}-app"
  }
  spec {
    selector = {
      app = kubernetes_pod.example.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 3000
      target_port = 3000
    }

    type = "NodePort"
  }
}

#Deploying container pod
resource "kubernetes_pod" "example" {
  metadata {
    name = "terraform-example"
    labels = {
      app = "${var.project_id}-app"
    }
  }

  spec {
    container {
      image = "us-central1-docker.pkg.dev/gcp-devops-376520/my-repository/latest-image@sha256:b10e80b6ff4a87797d98685a8e6f3044911fb95d4f317fdc2d4cf3a599077e28"
      name  = "example"

      port {
        container_port = 3000
      }
    }
  }
}*/