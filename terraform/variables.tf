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

variable "db_host" {
  type = "string"
}

variable "db_port" {
  type = "string"
}

variable "qtickets_endpoint" {
    type = "string"
}

variable "qtickets_token" {
    type = "string"
}
