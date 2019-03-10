resource "dnsimple_record" "apiserver" {
  domain = "${var.domain}"
  name   = "k"
  value  = "${element(yandex_compute_instance.masters.*.network_interface.0.nat_ip_address, count.index)}"
  type   = "A"
  ttl    = 3600

  count = "${var.master_count}"
}

resource "dnsimple_record" "frontend" {
  domain = "${var.domain}"
  name   = ""
  value  = "${element(yandex_compute_instance.masters.*.network_interface.0.nat_ip_address, count.index)}"
  type   = "A"
  ttl    = 3600

  count = "${var.master_count}"
}
