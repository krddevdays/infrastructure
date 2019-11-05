variable "docker_swarm_ssh_key_public" {
  type = "string"
}

variable "docker_swarm_ssh_key_private" {
  type = "string"
}

variable "domain" {
  type = "string"
}

variable "frontend_image_name" {
  type = "string"
}

variable "frontend_image_version" {
  type = "string"
}

variable "backend_image_name" {
  type = "string"
}

variable "backend_image_version" {
  type = "string"
}

variable "certbot_email" {
  type = "string"
}

variable "dhparams" {
  type = "string"
}

variable "dhparams_version" {
  type = "string"
}

variable "krddev_crt" {
  type = "string"
}

variable "krddev_crt_version" {
  type = "string"
}

variable "krddev_key" {
  type = "string"
}

variable "krddev_key_version" {
  type = "string"
}

variable "backend_secret_key" {
  type = "string"
}

variable "backend_db_name" {
  type = "string"
}

variable "backend_db_user" {
  type = "string"
}

variable "backend_db_password" {
  type = "string"
}

variable "backend_db_host" {
  type = "string"
}

variable "backend_db_port" {
  type = "string"
}

variable "qtickets_endpoint" {
    type = "string"
}

variable "qtickets_token" {
    type = "string"
}

variable "qtickets_secret" {
    type = "string"
}

variable "backend_sentry_dsn" {
    type = "string"
}

variable "frontend_sentry_dsn" {
    type = "string"
}

variable "frontend_sentry_token" {
    type = "string"
}

variable "imageboard_image_name" {
    type = "string"
}

variable "imageboard_image_version" {
    type = "string"
}

variable "imageboard_secret_key" {
    type = "string"
}

variable "imageboard_db_name" {
    type = "string"
}

variable "imageboard_db_user" {
    type = "string"
}

variable "imageboard_db_password" {
    type = "string"
}

variable "imageboard_db_host" {
    type = "string"
}

variable "imageboard_db_port" {
    type = "string"
}
