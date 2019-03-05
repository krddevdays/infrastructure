resource "null_resource" "master_inventory" {
  triggers {
    ansible_host = "${format("%s ansible_host=%s", element(yandex_compute_instance.masters.*.name, count.index), element(yandex_compute_instance.masters.*.network_interface.0.nat_ip_address, count.index))}"
  }

  count = "${var.master_count}"
}

data "template_file" "hosts_ini" {
  template = "${file("${path.module}/templates/hosts.ini.tpl")}"

  vars {
    # TODO: error here will be fixed in 0.12.0 https://github.com/hashicorp/terraform/issues/18160
    # For now comment-uncomment on size change. Sry
    # master_inventories = ""
    master_inventories = "${join("\n", null_resource.master_inventory.*.triggers.ansible_host)}"

    load_balancer_dns = "${dnsimple_record.apiserver.hostname}"
  }

  depends_on = ["null_resource.master_inventory"]
}

resource "local_file" "hosts_ini" {
  content  = "${data.template_file.hosts_ini.rendered}"
  filename = "${path.module}/../ansible/inventory/hosts.ini"
}
