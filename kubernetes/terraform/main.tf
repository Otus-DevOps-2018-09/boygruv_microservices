provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_container_cluster" "primary" {
  name               = "reddit-cluster"
  zone               = "${var.zone}"
  initial_node_count = 2
  enable_legacy_abac = false 

  #additional_zones = [
  #  "europe-west1-d",
  #  "europe-west1-c",
  #]

  master_auth {
    username = "boygruv"
    password = "Qwertyuiop1234567890"
  }

  node_config {
    disk_size_gb = 20

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

  }

  addons_config {
    kubernetes_dashboard {
      disabled = true
    }
  }

}

resource "google_compute_firewall" "reddit_otus" {
  name = "allow-reddit-default"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}
