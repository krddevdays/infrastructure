data "yandex_compute_image" "ubuntu_1804_lts" {
  family = "ubuntu-1804-lts"
}

data "template_file" "cloudinit" {
  template = "${file("${path.module}/cloudinit.yml.tpl")}"
}

resource "yandex_compute_instance" "docker_swarm" {
  name        = "docker-swarm"
  platform_id = "standard-v1"
  zone        = "${yandex_vpc_subnet.public.zone}"

  resources {
    cores  = 2
    memory = 2
  }

  metadata {
    user-data = "${data.template_file.cloudinit.rendered}"
    ssh-keys = "ubuntu:${file(var.docker_swarm_ssh_key_public)}"
  }

  boot_disk {
    initialize_params = {
      image_id    = "${data.yandex_compute_image.ubuntu_1804_lts.id}"
      name        = "docker-swarm-manager"
      size        = 100
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    nat       = true
  }

  connection {
    type = "ssh"
    user = "ubuntu"

    insecure = true

    private_key = "${file(var.docker_swarm_ssh_key_private)}"
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker swarm init --advertise-addr ${self.network_interface.0.ip_address}"
    ]
  }
}
