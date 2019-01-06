output "docker-host_external_ip" {
  value = "${google_compute_instance.docker.*.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "load_balancer_external_ip" {
  value = "${google_compute_forwarding_rule.docker-host-lb.ip_address}"
}
