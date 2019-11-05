provider "yandex" {
    version = "0.23"
}

provider "dnsimple" {
    version = "0.2"
}

provider "archive" {
    version = "1.3"
}

provider "null" {
    version = "2.1"
}

provider "template" {
    version = "2.1"
}

terraform {
  backend "s3" {
    key      = "production/key"
    bucket   = "krddevdays-terraform"

    skip_credentials_validation = true
    skip_get_ec2_platforms      = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
  }
}
