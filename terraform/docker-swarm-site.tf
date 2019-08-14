locals {
    docker_swarm_site_template_dir = "site-templates"
    docker_swarm_site_config_dir = "site-config"
}

resource "dnsimple_record" "frontend" {
    domain = "${var.domain}"
    name = ""
    value = "${yandex_compute_instance.docker_swarm.network_interface.0.nat_ip_address}"
    type = "A"
    ttl = 600
}

resource "dnsimple_record" "backend" {
    domain = "${var.domain}"
    name = "backend"
    value = "${yandex_compute_instance.docker_swarm.network_interface.0.nat_ip_address}"
    type = "A"
    ttl = 600
}

resource "template_dir" "docker_swarm_site" {
    source_dir = "${path.module}/${local.docker_swarm_site_template_dir}"
    destination_dir = "${path.cwd}/${local.docker_swarm_site_config_dir}"

    vars = {
        frontend_image_name = "${var.frontend_image_name}"
        frontend_image_version = "${var.frontend_image_version}"
        frontend_domain = "${dnsimple_record.frontend.hostname}"

        backend_image_name = "${var.backend_image_name}"
        backend_image_version = "${var.backend_image_version}"
        backend_domain = "${dnsimple_record.backend.hostname}"

        backend_cors_list = "https://${dnsimple_record.frontend.hostname}"

        backend_secret_key = "${var.backend_secret_key}"

        backend_db_name = "${var.backend_db_name}"
        backend_db_user = "${var.backend_db_user}"
        backend_db_password = "${var.backend_db_password}"

        backend_sentry_dsn = "${var.backend_sentry_dsn}"
        frontend_sentry_dsn = "${var.frontend_sentry_dsn}"
        frontend_sentry_token = "${var.frontend_sentry_token}"

        db_host = "${var.db_host}"
        db_port = "${var.db_port}"

        email = "${var.certbot_email}"

        qtickets_endpoint = "${var.qtickets_endpoint}"
        qtickets_token = "${var.qtickets_token}"
        qtickets_secret = "${var.qtickets_secret}"
    }
}

data "archive_file" "docker_swarm_site_config" {
    type        = "zip"
    source_dir = "${template_dir.docker_swarm_site.destination_dir}"
    output_path = "site-config.zip"
}

resource "null_resource" "docker_stack_site" {
    triggers {
        hash = "${data.archive_file.docker_swarm_site_config.output_sha}"
    }

    connection {
        type = "ssh"
        user = "ubuntu"
        host = "${yandex_compute_instance.docker_swarm.network_interface.0.nat_ip_address}"

        insecure = true

        private_key = "${file(var.docker_swarm_ssh_key_private)}"
        agent = false
    }

    provisioner "remote-exec" {
        inline = [
            "sudo docker image prune -f"
        ]
    }

    provisioner "file" {
        source = "${template_dir.docker_swarm_site.destination_dir}"
        destination = "/home/ubuntu"
    }

    provisioner "file" {
        source = "${var.dhparams}"
        destination = "/home/ubuntu/${local.docker_swarm_site_config_dir}/dhparams.pem"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod 600 /home/ubuntu/${local.docker_swarm_site_config_dir}/dhparams.pem",
            "cd /home/ubuntu/${local.docker_swarm_site_config_dir}",
            "sudo docker stack deploy -c site.yml site"
        ]
    }

    provisioner "file" {
        source = "docker-stack-wait.sh"
        destination = "/tmp/docker-stack-wait.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/docker-stack-wait.sh",
            "sudo /tmp/docker-stack-wait.sh site",
        ]
    }
}
