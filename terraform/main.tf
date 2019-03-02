data "yandex_compute_image" "ubuntu_1804_lts" {
  family = "ubuntu-1804-lts"
}

data "template_file" "kube_basic" {
  template = "${file("${path.module}/templates/kube-basic-config.yml.tpl")}"
}

resource "yandex_compute_instance" "masters" {
  name        = "master-${count.index}"
  platform_id = "standard-v1"
  zone        = "${element(yandex_vpc_subnet.public.*.zone, count.index % length(yandex_vpc_subnet.public.*.zone))}"

  resources {
    cores  = 2
    memory = 2
  }

  metadata {
    user-data = "${data.template_file.kube_basic.rendered}"
  }

  boot_disk {
    auto_delete = true # boom

    initialize_params = {
      image_id    = "${data.yandex_compute_image.ubuntu_1804_lts.id}"
      name        = "boot"
      description = "master-${count.index}-boot"
      size        = 10
    }
  }

  network_interface {
    subnet_id = "${element(yandex_vpc_subnet.public.*.id, count.index % length(yandex_vpc_subnet.public.*.id))}"
    nat       = true
  }

  metadata {
    backend  = "kubernetes"
    role     = "master"
    ssh-keys = "ubuntu:${file("./../keys/id_rsa.pub")}"
  }

  count = "${var.master_count}"
}
