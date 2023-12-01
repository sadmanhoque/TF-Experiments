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

resource "kubernetes_service" "my_service" {
  metadata {
    name = "my-service"
  }

  spec {
    selector = {
      app = "react-app"
    }

    port {
      protocol = "TCP"
      port     = 3000
      target_port = 3000  # Replace with the port your application is listening on
    }

    type = "LoadBalancer"
  }
}
