resource "yandex_vpc_network" "production" {
  name = "production"
}

resource "yandex_vpc_subnet" "public" {
  v4_cidr_blocks = ["${cidrsubnet("10.0.0.0/8", 8, count.index)}"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.production.id}"

  count = "${var.subnet_count}"
}
