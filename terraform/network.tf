resource "yandex_vpc_network" "docker_swarm" {
  name = "docker-swarm"
}

resource "yandex_vpc_subnet" "public" {
  v4_cidr_blocks = ["${cidrsubnet("10.1.0.0/16", 8, count.index)}"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.docker_swarm.id}"
}
