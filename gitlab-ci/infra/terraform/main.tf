provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_project_metadata" "ssh_keys" {
    metadata {
      ssh-keys = "${var.username}:${file("~/.ssh/appuser.pub")}"
    }
}

resource "google_compute_instance" "gitlab" {
  name         = "gitlab-ci"
  # 1 CPU, 4GB
  machine_type = "custom-1-4096"
  zone         = "${var.zone}"
  tags         = ["gitlab"]

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.disk_image}",
      size  = "${var.disk_size}"
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
    ssh-keys = "${var.username}:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "${var.username}"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get -y install python"]

    connection {
      type        = "ssh"
      user        = "${var.username}"
      private_key = "${file(var.private_key_path)}"
    }
  }

  # Устанавливаем docker-ce
  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.username} -i '${self.network_interface.0.access_config.0.assigned_nat_ip},' --private-key ${var.private_key_path} --extra-vars 'external_ip=${self.network_interface.0.access_config.0.assigned_nat_ip}' ../../../docker-monolith/infra/ansible/playbooks/docker_install.yml ../playbooks/gitlab_init.yml" 
  }

}


resource "google_compute_firewall" "firewall_gitlab" {
  name = "allow-gitlab"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["80","443"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["gitlab"]
}

