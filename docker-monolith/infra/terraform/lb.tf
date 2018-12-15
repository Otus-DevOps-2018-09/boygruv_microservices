resource "google_compute_target_pool" "docker-host-pool" {
  name = "docker-host-pool"

  instances = [
    "${google_compute_instance.docker.*.self_link}",
  ]

  health_checks = [
    "${google_compute_http_health_check.docker-host-check.name}",
  ]
}

resource "google_compute_http_health_check" "docker-host-check" {
  name               = "docker-host-check"
  request_path       = "/"
  check_interval_sec = 5
  timeout_sec        = 2
  port               = "9292"
}

resource "google_compute_forwarding_rule" "docker-host-lb" {
  name       = "docker-host-lb"
  target     = "${google_compute_target_pool.docker-host-pool.self_link}"
  port_range = "9292"
} 
