provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_project_metadata" "ssh_keys" {
    metadata {
      ssh-keys = "appuser:${file("~/.ssh/appuser.pub")}"
    }
}

resource "google_compute_instance" "docker" {
  name         = "docker-host${count.index+1}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["docker-host"]
  count        = "${var.count}"

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать ephemeral IP для доступа из Интернет
    access_config {}
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

}

resource "google_compute_firewall" "firewall_otus" {
  name = "allow-otus-default"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["docker-host"]
}
