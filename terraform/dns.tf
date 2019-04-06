resource "dnsimple_record" "frontend" {
  domain = "${var.domain}"
  name   = ""
  value  = "${yandex_compute_instance.docker_swarm.network_interface.0.nat_ip_address}"
  type   = "A"
  ttl    = 600
}

resource "dnsimple_record" "backend" {
  domain = "${var.domain}"
  name   = "backend"
  value  = "${yandex_compute_instance.docker_swarm.network_interface.0.nat_ip_address}"
  type   = "A"
  ttl    = 600
}
