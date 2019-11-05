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

resource "dnsimple_record" "ch" {
    domain = "${var.domain}"
    name = "ch"
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

        backend_db_host = "${var.backend_db_host}"
        backend_db_port = "${var.backend_db_port}"

        email = "${var.certbot_email}"

        qtickets_endpoint = "${var.qtickets_endpoint}"
        qtickets_token = "${var.qtickets_token}"
        qtickets_secret = "${var.qtickets_secret}"

        dhparams_version = "${var.dhparams_version}"
        krddev_crt_version = "${var.krddev_crt_version}"
        krddev_key_version = "${var.krddev_key_version}"

        imageboard_domain = "${dnsimple_record.ch.hostname}"
        imageboard_image_name = "${var.imageboard_image_name}"
        imageboard_image_version = "${var.imageboard_image_version}"
        imageboard_secret_key = "${var.imageboard_secret_key}"
        imageboard_db_name = "${var.imageboard_db_name}"
        imageboard_db_user = "${var.imageboard_db_user}"
        imageboard_db_password = "${var.imageboard_db_password}"
        imageboard_db_host = "${var.imageboard_db_host}"
        imageboard_db_port = "${var.imageboard_db_port}"
        imageboard_s3_access_key_id = "${yandex_iam_service_account_static_access_key.s3.access_key}"
        imageboard_s3_secret_access_key = "${yandex_iam_service_account_static_access_key.s3.secret_key}"
        imageboard_s3_storage_bucket_name = "${yandex_storage_bucket.imageboard.id}"
        imageboard_s3_region_name = "ru-central1"
        imageboard_s3_endpoint_url = "https://storage.yandexcloud.net"
        imageboard_media_url = "https://storage.yandexcloud.net/${yandex_storage_bucket.imageboard.id}/"
    }
}

resource "yandex_iam_service_account" "s3" {
    name = "object-manager"
    description = "service account to manage S3"
}

resource "yandex_iam_service_account_iam_binding" "editor" {
    service_account_id = "${yandex_iam_service_account.s3.id}"
    role = "editor"

    members = [
        "serviceAccount:${yandex_iam_service_account.s3.id}"
    ]
}

resource "yandex_iam_service_account_static_access_key" "s3" {
    service_account_id = "${yandex_iam_service_account.s3.id}"
    description = "static access key for object storage"
}

resource "yandex_storage_bucket" "imageboard" {
    bucket = "krd-ch"
    acl = "public-read"

    access_key = "${yandex_iam_service_account_static_access_key.s3.access_key}"
    secret_key = "${yandex_iam_service_account_static_access_key.s3.secret_key}"

    depends_on = [
        "yandex_iam_service_account_iam_binding.editor"
    ]
}

data "archive_file" "docker_swarm_site_config" {
    type = "zip"
    source_dir = "${template_dir.docker_swarm_site.destination_dir}"
    output_path = "site-config.zip"

    depends_on = [
        "template_dir.docker_swarm_site"
    ]
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

    provisioner "file" {
        source = "${var.krddev_crt}"
        destination = "/home/ubuntu/${local.docker_swarm_site_config_dir}/STAR_krd_dev.crt"
    }

    provisioner "file" {
        source = "${var.krddev_key}"
        destination = "/home/ubuntu/${local.docker_swarm_site_config_dir}/STAR_krd_dev.key"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod 600 /home/ubuntu/${local.docker_swarm_site_config_dir}/dhparams.pem",
            "chmod 600 /home/ubuntu/${local.docker_swarm_site_config_dir}/STAR_krd_dev.crt",
            "chmod 600 /home/ubuntu/${local.docker_swarm_site_config_dir}/STAR_krd_dev.key",
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
